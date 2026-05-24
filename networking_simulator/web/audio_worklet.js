// Audio worklet for the realtime voice loop.
//
// Two processors:
//   - mic-processor: captures mic input at the AudioContext's native sample
//     rate, linearly resamples to 16 kHz mono, posts Int16Array chunks
//     (little-endian PCM) via this.port.postMessage. Dart base64-encodes
//     and ships them as Gemini Live `realtimeInput.audio` frames.
//   - playback-processor: receives 24 kHz Int16 PCM chunks from Dart,
//     resamples to the output sample rate, plays them seamlessly via
//     the worklet's render callback.
//
// The processors run on the AudioWorklet thread; main-thread Dart talks
// to them via MessagePort. Buffers are transferred where possible to
// avoid copies.

const TARGET_INPUT_RATE = 16000;
const SOURCE_OUTPUT_RATE = 24000;

class MicProcessor extends AudioWorkletProcessor {
  constructor() {
    super();
    // Running resample state: fractional read index into the input.
    this._readIdx = 0;
    // Buffer to coalesce small Float32 frames into ~100 ms chunks before
    // shipping over postMessage. At 16 kHz, that's 1600 samples per chunk.
    this._buf = new Float32Array(1600);
    this._fill = 0;
  }

  process(inputs) {
    const input = inputs[0];
    if (!input || !input[0]) return true;
    const ch = input[0];
    const ratio = sampleRate / TARGET_INPUT_RATE;

    let i = this._readIdx;
    while (i < ch.length) {
      const i0 = Math.floor(i);
      const i1 = Math.min(i0 + 1, ch.length - 1);
      const frac = i - i0;
      const sample = ch[i0] * (1 - frac) + ch[i1] * frac;
      this._buf[this._fill++] = sample;
      if (this._fill === this._buf.length) {
        this._flush();
      }
      i += ratio;
    }
    this._readIdx = i - ch.length;
    return true;
  }

  _flush() {
    const pcm = new Int16Array(this._fill);
    for (let i = 0; i < this._fill; i++) {
      let s = Math.max(-1, Math.min(1, this._buf[i]));
      pcm[i] = s < 0 ? s * 0x8000 : s * 0x7fff;
    }
    this.port.postMessage(pcm.buffer, [pcm.buffer]);
    this._fill = 0;
  }
}

class PlaybackProcessor extends AudioWorkletProcessor {
  constructor() {
    super();
    // Queue of Float32Array buffers, already at output sample rate.
    this._queue = [];
    this._head = null;
    this._headOffset = 0;
    this.port.onmessage = (e) => {
      const { pcm, sourceRate } = e.data;
      const samples = new Int16Array(pcm);
      const float = new Float32Array(samples.length);
      for (let i = 0; i < samples.length; i++) float[i] = samples[i] / 0x8000;
      const resampled = sourceRate === sampleRate
        ? float
        : this._resample(float, sourceRate, sampleRate);
      this._queue.push(resampled);
    };
  }

  _resample(input, srcRate, dstRate) {
    const ratio = srcRate / dstRate;
    const outLen = Math.floor(input.length / ratio);
    const out = new Float32Array(outLen);
    for (let i = 0; i < outLen; i++) {
      const srcIdx = i * ratio;
      const i0 = Math.floor(srcIdx);
      const i1 = Math.min(i0 + 1, input.length - 1);
      const frac = srcIdx - i0;
      out[i] = input[i0] * (1 - frac) + input[i1] * frac;
    }
    return out;
  }

  process(_, outputs) {
    const out = outputs[0][0];
    let written = 0;
    while (written < out.length) {
      if (this._head === null) {
        if (this._queue.length === 0) break;
        this._head = this._queue.shift();
        this._headOffset = 0;
      }
      const remaining = this._head.length - this._headOffset;
      const wantToWrite = out.length - written;
      const take = Math.min(remaining, wantToWrite);
      for (let i = 0; i < take; i++) out[written + i] = this._head[this._headOffset + i];
      written += take;
      this._headOffset += take;
      if (this._headOffset >= this._head.length) this._head = null;
    }
    // Pad remainder with silence so we don't pop.
    for (let i = written; i < out.length; i++) out[i] = 0;
    // Notify the main thread when the queue is empty so the UI can flip
    // `isAiSpeaking` to false.
    if (this._queue.length === 0 && this._head === null && written < out.length) {
      this.port.postMessage({ idle: true });
    }
    return true;
  }
}

registerProcessor('mic-processor', MicProcessor);
registerProcessor('playback-processor', PlaybackProcessor);
