# ConnectAI (AI Networking Simulator)
> Team: Git Happens
> 
> ## Table of Contents
* [Problem-Solution Fit](#problem-solution-fit)
* [Functional Completeness](#functional-completeness)
* [Innovation & Originality](#innovation-and-originality)
* [Technical Execution](#technical-execution)
* [UX & Design](#ux-and-design)
* [Learning & Ambition](#learning-and-ambition)
* [Citations](#citations)

## Problem-Solution Fit
- <ins>Problem:</ins> **Verbal communication**  is a key part of daily life and often shapes how others perceive us in professional settings like networking and cold calling. Yet it can be difficult: a 2024 BankMyCell survey found 81% of millennials feel apprehensive before making phone calls, and a 2025 AXA Insurance Belgium study reported 49% of Gen Z avoid calls due to anxiety (KallyAI, 2026). **Phone (telephonic) anxiety**  can overlap with social anxiety and lead to call‑avoidance driven by discomfort, uncertainty, or negative emotions, effects that may be stronger in professional contexts (KallyAI, 2026). **Networking is also intimidating**  for reasons such as fear of judgment, not knowing what to say (McMaster University, 2025), fear of making mistakes in high‑stakes situations, or past negative experiences (Executive Recruit, 2024). Whether you need practice to overcome anxiety or you’re an inexperienced student or professional, **ConnectAI aims to provide practical, accessible experience with networking and calls to help develop verbal communication skills anytime, anywhere, at any career stage.**
- <ins>Solutions & Benefits:</ins> ConnectAI is an AI‑powered networking simulator that provides both **customizable and fixed personas plus real‑time verbal feedback on your interactions**. The platform uses **human‑like simulations tailored to your industry, role, and goals** so practice translates naturally to real‑world situations. In addition to verbal feedback, ConnectAI gives **written summaries and performance metrics after each session so you can track progress over time.** Acting as a form of exposure practice, it helps users prepare for networking and cold‑calling, reduce anxiety, and build confidence. **Benefits include improved communication skills (general and industry‑specific), stronger rapport‑building, more effective self‑marketing, and increased access to professional opportunities and resources. Let your communication be the reason you stand out, honed through targeted practice with ConnectAI.**

## Functional Completeness
- <ins>What Works:</ins>
  - **User registration** collects name, profession/role (student, early-mid-senior professional), primary networking goals (land a job, investor pitch, general networking, client or sales calls), and industry; these can be edited later in profile settings. **Profile** displays other metrics and user preferences (similar to the homepage).
  - After setup, the **homepage** shows upcoming practice sessions, competency progress (e.g., confidence, clarity), and persona interaction metrics (e.g., most frequently used persona).
  - **Practice page** lets users choose or create personas (e.g., recruiter, hiring manager), select conversation style and difficulty, set industry context, and receive both verbal and written tailored feedback.
  - The **scheduling page** displays practice calls with dates/times, practice-frequency data, and AI recommendations for when to practice. Furthermore, psychology notes that notifications are dopamine-inducing ‘attention-triggers’ that drive curiosity and improve engagement towards a task (Cse, 2026). A single "your session is starting" ping can be forgettable; here is a proposed remedy: Reminders for upcoming practice sessions at T‑60, T‑15, and T‑0.
- <ins>Future Additions:</ins>
  - Tiered scheduling for real schedules: ConnectAI sends notifications/reminders for upcoming sessions at multiple increments between 24 hours before the session and the session start (T‑0).
  - Broaden audience coverage to include unlisted professions/roles (e.g., career transitioners), as well as industries.
  - Add calendar integration to allow exporting/importing practice sessions to personal calendars (and vice-versa). Potentially allowing ConnectAI to bridge real-life schedules with practice: prepare users for upcoming interviews, networking events, or HR meetings based on their inputted calendar.
  - Improve persona realism by incorporating real‑world data and judging criteria from industry professionals (e.g., HR recruiters and hiring managers).

## Innovation and Originality
- ConnectAI’s originality shines in its **humanistic approach to networking, cold‑calling, and verbal‑communication practice.** It offers both customizable and fixed personas for sessions and provides multimodal, **personalized interactions and feedback—voice‑to‑voice and text‑based.** We also plan UX‑friendly features such as **tiered scheduling** to keep upcoming practice sessions memorable and users engaged.
  
## Technical Execution
-  Web app built with Google’s Flutter framework — primary languages: Dart and C++. The backend runs in the same browser bundle as the UI, so there is no HTTP boundary, no /api/* routes, and no JSON-over-HTTP between layers.
-  Voice-to-voice connection implemented with Gemini Live over WebSocket.
-  Firestore (Firebase- Google) used to store practice sessions, transcripts, summaries, and custom personas.
-  Cursor IDE for code editing, terminal, debugging, and integrations; used Cursor AI, Claude, and ChatGPT to streamline implementation.
  
## UX and Design
-  ConnectAI features a **simple, effective interface** with light and dark modes. It avoids crowding by displaying essential features, ensures smooth transitions between pages, and uses color and size to make important content salient when clicked. Intuitive icons improve clarity and comprehension.
  
## Learning and Ambition
-  Git Happens pushed itself on multiple fronts. During brainstorming and planning we evaluated how best to achieve ConnectAI’s goals: what users would (or wouldn’t) benefit from, which incentives to offer, and how to reach target audiences. Technically, team members learned Google’s Flutter framework and Dart for the first time. Through iterative review and refinement, Git Happens produced an AI networking‑simulator demo with a user‑friendly interface that highlights the most important features, all within the hackathon submission deadline.

## Citations
- Executive Recruit. (2024). *The Importance of Mastering Networking and Cold Call Communication: A Critical Skill for Everyone, Not Just Salespeople.* LinkedIn. https://www.linkedin.com/pulse/importance-mastering-networking-cold-call-communication-je8ae/
- McMaster University. (2025). *Networking: Navigating the Anxiety.* https://studentsuccess.mcmaster.ca/networking-navigating-the-anxiety/
- Cse, S. (2026). *The Psychology of Notifications: How Technology Hacks Human Attention.* Medium. https://medium.com/@sandra.cse2024/the-psychology-of-notifications-how-technology-hacks-human-attention-486c5af7c756
- KallyAI. (2026). *Phone Anxiety Statistics 2026: Data, Demographics & What Helps.* https://kallyai.com/resources/phone-anxiety-statistics#citation-axa-2025






