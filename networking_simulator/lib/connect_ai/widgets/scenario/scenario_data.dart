import 'package:flutter/material.dart';

/// Display metadata for industry chips (UI only).
class IndustryOption {
  const IndustryOption({required this.label, required this.icon});

  final String label;
  final IconData icon;
}

const kScenarioIndustries = <IndustryOption>[
  IndustryOption(label: 'Technology', icon: Icons.computer_rounded),
  IndustryOption(label: 'Finance', icon: Icons.account_balance_rounded),
  IndustryOption(label: 'Healthcare', icon: Icons.local_hospital_rounded),
  IndustryOption(label: 'Marketing', icon: Icons.campaign_rounded),
  IndustryOption(label: 'Human Resources', icon: Icons.groups_rounded),
  IndustryOption(label: 'Consulting', icon: Icons.handshake_rounded),
  IndustryOption(label: 'Education', icon: Icons.school_rounded),
  IndustryOption(label: 'Retail', icon: Icons.storefront_rounded),
  IndustryOption(label: 'Manufacturing', icon: Icons.precision_manufacturing_rounded),
  IndustryOption(label: 'Non-profit', icon: Icons.volunteer_activism_rounded),
  IndustryOption(label: 'Government', icon: Icons.account_balance_outlined),
  IndustryOption(label: 'Engineering', icon: Icons.engineering_rounded),
  IndustryOption(label: 'Media', icon: Icons.movie_creation_outlined),
  IndustryOption(label: 'Sales', icon: Icons.trending_up_rounded),
  IndustryOption(label: 'Entrepreneurship', icon: Icons.rocket_launch_rounded),
  IndustryOption(label: 'Hospitality', icon: Icons.hotel_rounded),
  IndustryOption(label: 'Legal', icon: Icons.gavel_rounded),
  IndustryOption(label: 'Real Estate', icon: Icons.apartment_rounded),
];

String conversationStylePreviewLabel(String style) => switch (style) {
      'Formal' => 'Professional conversation',
      'Conversational' => 'Conversational style',
      'Challenging' => 'Challenging conversation',
      _ => '$style style',
    };

String difficultyPreviewLabel(String difficulty) => '$difficulty difficulty';

String industryPreviewLabel(String industry) => '$industry industry';
