import 'package:flutter/material.dart';

/// Replace this with your real contact address. It's used by the
/// "Contact Us" block in the app footer (see widgets/app_footer.dart)
/// and by the /contact page, both of which open the user's mail client
/// via a mailto: link when tapped.
const String kContactEmail = 'karthik08dev@gmail.com';

/// A reason someone might get in touch, shown as a tappable card on the
/// Contact page. Each pre-fills the mailto subject line so the right
/// context is obvious before the user even starts typing.
class ContactCategory {
  final String label;
  final String description;
  final IconData icon;
  final String subject;
  const ContactCategory({
    required this.label,
    required this.description,
    required this.icon,
    required this.subject,
  });
}

const List<ContactCategory> kContactCategories = [
  ContactCategory(
    label: 'General Questions',
    description: 'Anything about how FLogo Generator works or how to use it.',
    icon: Icons.help_outline,
    subject: 'FLogo Generator — General question',
  ),
  ContactCategory(
    label: 'Bug Report',
    description: 'Something didn\'t generate correctly, or the app broke.',
    icon: Icons.bug_report_outlined,
    subject: 'FLogo Generator — Bug report',
  ),
  ContactCategory(
    label: 'Feature Request',
    description: 'A platform, option, or icon type you\'d like to see added.',
    icon: Icons.lightbulb_outline,
    subject: 'FLogo Generator — Feature request',
  ),
  ContactCategory(
    label: 'Privacy Question',
    description: 'Questions about the Privacy Policy or how your data is handled.',
    icon: Icons.privacy_tip_outlined,
    subject: 'FLogo Generator — Privacy question',
  ),
  ContactCategory(
    label: 'Advertising',
    description: 'Questions about ads shown on this site.',
    icon: Icons.campaign_outlined,
    subject: 'FLogo Generator — Advertising question',
  ),
  ContactCategory(
    label: 'General Feedback',
    description: 'Anything else — good, bad, or just an idea worth sharing.',
    icon: Icons.chat_bubble_outline,
    subject: 'FLogo Generator — Feedback',
  ),
];
