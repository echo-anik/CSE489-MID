# Academic Integrity Statement

## Course Information
- **Course**: CSE489 - Mobile Application Development
- **Project**: Flutter Landmark Management Application
- **Semester**: [Fill in your semester]
- **Submission Date**: [Fill in submission date]

---

## Declaration of Original Work

### Student Information

**I hereby declare that this project submission is my own original work:**

```
Student Name: _________________________________

Student ID: ___________________________________

Email: ________________________________________

Section: ______________________________________

Date: _________________________________________

Signature: ____________________________________
```

### Academic Integrity Statement

I, **[Your Name]**, affirm that:

1. **Original Work**: This project represents my own individual work and effort. All code written by me is original unless otherwise cited.

2. **Proper Attribution**: I have properly acknowledged and cited all sources of information, code snippets, libraries, and resources used in this project.

3. **No Plagiarism**: I have not copied code from other students, online sources, or any other medium without proper attribution and modification.

4. **Individual Effort**: While I may have discussed concepts and approaches with peers, all implementation and code writing was done individually.

5. **AI Tool Disclosure**: I have disclosed all AI tools used in this project and explained how they were utilized (see section below).

6. **Understanding**: I understand all the code in this project and can explain any part of it if questioned.

7. **Consequences**: I understand that any violation of academic integrity may result in disciplinary action, including but not limited to failure in the course.

---

## AI Tool Usage Disclosure

### Tools Used

I acknowledge using the following AI-powered tools during the development of this project:

#### 1. ChatGPT (OpenAI)
- **Version**: [e.g., GPT-4, GPT-3.5]
- **Usage Frequency**: [e.g., Occasional, Frequent, Rare]
- **Purpose**: [Describe general purpose]

#### 2. Claude (Anthropic)
- **Version**: [e.g., Claude 3.5 Sonnet]
- **Usage Frequency**: [e.g., Occasional, Frequent, Rare]
- **Purpose**: [Describe general purpose]

#### 3. GitHub Copilot
- **Usage**: [Yes/No]
- **Usage Frequency**: [e.g., Occasional, Frequent, Rare]
- **Purpose**: [Describe general purpose]

#### 4. Other AI Tools
- **Tool Name**: [e.g., Tabnine, Codeium, etc.]
- **Purpose**: [Describe purpose]

### Specific Use Cases

Below is a detailed breakdown of how AI tools were used in this project:

#### Boilerplate Code Generation

**What was generated**:
- Flutter project structure setup commands
- Basic widget templates (StatelessWidget, StatefulWidget)
- Model class boilerplate (constructors, toJson, fromJson)
- Provider boilerplate setup

**How it was modified**:
- Customized field names to match project requirements
- Added project-specific validation logic
- Integrated with custom landmark model
- Modified to fit project architecture

**Example**:
```dart
// AI-generated boilerplate
class LandmarkModel {
  final String id;
  final String name;

  LandmarkModel({required this.id, required this.name});
}

// My customization
class Landmark {
  final String id;
  final String name;
  final String description;
  final double latitude;
  final double longitude;
  final String? imageUrl;
  final DateTime createdAt;

  // Added custom validation and business logic
  Landmark({
    required this.id,
    required this.name,
    required this.description,
    required this.latitude,
    required this.longitude,
    this.imageUrl,
    DateTime? createdAt,
  }) : this.createdAt = createdAt ?? DateTime.now();

  // Custom methods added by me
  Map<String, dynamic> toJson() { /* custom implementation */ }
  factory Landmark.fromJson(Map<String, dynamic> json) { /* custom implementation */ }
}
```

#### Error Debugging Assistance

**Errors debugged with AI help**:
1. **Google Maps API key configuration issue**
   - AI suggested checking AndroidManifest.xml and Info.plist
   - I identified the specific missing permission in my project
   - Applied fix with proper understanding

2. **Image picker null safety error**
   - AI explained null safety in Flutter 3.x
   - I implemented proper null checking in my code
   - Added fallback handling for cancelled selections

3. **Provider state management rebuild issue**
   - AI explained Provider's notifyListeners mechanism
   - I restructured my code to optimize rebuilds
   - Implemented custom solution for my use case

**How AI was used**:
- Explained error messages and their causes
- Suggested potential solutions
- Provided documentation links
- I evaluated suggestions and implemented appropriate fixes

#### Documentation Writing

**AI-assisted documentation**:
- README.md structure suggestions
- Inline code comments templates
- API documentation format

**My contribution**:
- Wrote all project-specific content
- Added custom setup instructions
- Documented actual implementation details
- Created original examples from my code

#### Design and Architecture Suggestions

**AI provided suggestions for**:
- Flutter project folder structure
- State management approach (Provider vs Riverpod vs Bloc)
- Widget composition patterns
- Service layer architecture

**My decisions**:
- Evaluated multiple suggestions
- Chose Provider based on project requirements
- Implemented custom folder structure fitting my needs
- Made architectural decisions independently

**Example**:
```
AI suggested: "Use Bloc for state management"
My decision: "Used Provider because it's simpler for this project scope and I'm more familiar with it"

AI suggested: "Create separate repositories for data access"
My decision: "Used a simpler service layer approach as project doesn't require that complexity"
```

### Percentage Breakdown

Estimated contribution breakdown for this project:

| Component | My Original Work | AI-Assisted | Third-Party Libraries |
|-----------|------------------|-------------|----------------------|
| UI Implementation | 85% | 10% | 5% |
| Business Logic | 90% | 5% | 5% |
| Data Models | 80% | 15% | 5% |
| State Management | 85% | 10% | 5% |
| Error Handling | 95% | 5% | 0% |
| Documentation | 70% | 20% | 10% |
| Testing | 90% | 5% | 5% |

**Overall Contribution**: Approximately 85% original work, 10% AI-assisted, 5% third-party libraries

---

## Third-Party Resources

### Flutter Packages Used

All packages obtained from [pub.dev](https://pub.dev):

#### Core Functionality
1. **google_maps_flutter** (^2.5.0)
   - **Purpose**: Map view implementation
   - **Source**: https://pub.dev/packages/google_maps_flutter
   - **Customization**: Custom marker styling, bottom sheet integration

2. **provider** (^6.1.1)
   - **Purpose**: State management
   - **Source**: https://pub.dev/packages/provider
   - **Customization**: Custom provider classes for landmark management

3. **image_picker** (^1.0.5)
   - **Purpose**: Select images from gallery/camera
   - **Source**: https://pub.dev/packages/image_picker
   - **Customization**: Custom error handling, image validation

#### Bonus Features
4. **sqflite** (^2.3.0)
   - **Purpose**: Offline data caching
   - **Source**: https://pub.dev/packages/sqflite
   - **Customization**: Custom schema for landmark storage

5. **firebase_core** (^2.24.0) & **firebase_auth** (^4.15.0)
   - **Purpose**: User authentication
   - **Source**: https://pub.dev/packages/firebase_core
   - **Customization**: Custom authentication flow

#### UI/UX Enhancement
6. **flutter_slidable** (^3.0.0)
   - **Purpose**: Swipe actions in list view
   - **Source**: https://pub.dev/packages/flutter_slidable
   - **Customization**: Custom swipe action buttons

7. **geolocator** (^10.1.0)
   - **Purpose**: Get device location
   - **Source**: https://pub.dev/packages/geolocator
   - **Customization**: Permission handling, error management

### Stack Overflow References

Questions referenced (with proper understanding and adaptation):

1. **Google Maps marker customization**
   - URL: [stackoverflow.com/questions/...]
   - What I learned: How to create custom marker icons
   - How I used it: Implemented custom landmark markers with my own design

2. **Flutter form validation**
   - URL: [stackoverflow.com/questions/...]
   - What I learned: Best practices for form validation in Flutter
   - How I used it: Created custom validators for my landmark form

3. **Provider state management pattern**
   - URL: [stackoverflow.com/questions/...]
   - What I learned: Proper way to structure Provider classes
   - How I used it: Built my own LandmarkProvider with custom logic

### Tutorial Resources

1. **Flutter Official Documentation**
   - URL: https://docs.flutter.dev
   - Used for: Understanding Flutter widgets, state management, navigation
   - Sections referenced: Widget catalog, cookbook, API reference

2. **Google Maps Flutter Tutorial**
   - URL: [Google Developers documentation]
   - Used for: Initial Google Maps setup and basic implementation
   - Customization: Extended with custom features for landmarks

3. **Firebase Flutter Setup**
   - URL: https://firebase.google.com/docs/flutter/setup
   - Used for: Firebase configuration and authentication setup
   - Customization: Implemented custom authentication flow

### Asset Sources

#### Icons and Images

1. **App Icons**
   - Source: [e.g., Flaticon, Icons8, custom-made]
   - License: [e.g., Free for personal use, Attribution required]
   - Usage: App launcher icon, marker icons

2. **Placeholder Images**
   - Source: [e.g., Unsplash, Pexels, custom]
   - License: [e.g., Free to use]
   - Usage: Default landmark images during development

3. **UI Icons**
   - Source: Material Design Icons (built into Flutter)
   - License: Apache 2.0
   - Usage: Navigation, action buttons, form fields

### Design Inspiration

1. **Google Maps App**
   - Inspired by: Marker interaction, bottom sheet design
   - My implementation: Custom bottom sheet with landmark-specific information

2. **Flutter Gallery App**
   - Inspired by: Material Design implementation, widget usage
   - My implementation: Adapted patterns for landmark management UI

---

## Original Contributions

### What I Created Entirely on My Own

#### 1. Custom Implementations

**Landmark Management Logic**:
- Complete CRUD operations for landmarks
- Custom validation rules specific to landmark data
- Unique business logic for managing geographic locations
- Integration between map markers and data models

**UI/UX Design**:
- Custom bottom sheet design for landmark details
- Unique layout for add/edit landmark form
- Custom color scheme and theming
- Original navigation flow between screens

**Error Handling System**:
- Custom error classes for different failure scenarios
- User-friendly error messages
- Graceful degradation for permission denials
- Offline mode handling

#### 2. Problem-Solving Approaches

**Challenge 1: Map Marker and Data Synchronization**
- Problem: Keeping map markers synchronized with landmark data
- My solution: Implemented a listener pattern using Provider that automatically updates markers when data changes
- Why original: Combined multiple concepts in a unique way for this specific use case

**Challenge 2: Image Storage and Retrieval**
- Problem: Efficiently storing and retrieving landmark images
- My solution: Created a custom image caching system with local file storage
- Why original: Designed specifically for landmark image requirements

**Challenge 3: Form Validation for Geographic Coordinates**
- Problem: Validating latitude/longitude input from users
- My solution: Custom validator that checks range and format with user-friendly messages
- Why original: Tailored validation logic for landmark geographic data

#### 3. Architecture Decisions

**Folder Structure**:
```
lib/
  models/          # My custom landmark model design
  screens/         # Screen organization based on features
  services/        # Service layer I designed for data management
  providers/       # State management structure I created
  widgets/         # Reusable widgets I built
  utils/          # Helper functions and constants I wrote
```

**Why this structure**: I chose this organization because it separates concerns clearly and makes the codebase maintainable. While common in Flutter, the specific implementation and organization is my own.

**State Management Choice**:
- Evaluated: Bloc, Riverpod, Provider, setState
- Chose: Provider
- Reasoning: Best balance of simplicity and functionality for this project scope
- This was my independent decision based on project requirements

#### 4. Custom Features

**Bottom Sheet Interaction**:
- Designed custom interaction between map markers and bottom sheet
- Implemented smooth animations and transitions
- Created unique layout showing all landmark details

**Swipe Actions**:
- Customized swipe gestures for edit/delete
- Added confirmation dialogs with custom messaging
- Implemented undo functionality (if included)

**Form Optimization**:
- Created auto-fill for coordinates when map marker is placed
- Implemented real-time form validation feedback
- Added image preview before upload

---

## Collaboration Statement

### Allowed Discussions with Peers

I discussed the following **concepts** with classmates (no code sharing):

1. **General Approach**:
   - Discussed which state management solution to use
   - Talked about project structure organization
   - Shared challenges faced with Google Maps API setup

2. **Conceptual Discussions**:
   - Debugging strategies for common Flutter errors
   - Best practices for form validation
   - Approaches to implement offline caching

3. **Learning Resources**:
   - Shared helpful documentation links
   - Recommended tutorial videos
   - Discussed Flutter package recommendations

**Important**: All discussions were conceptual only. No code was shared or copied from peers.

### Individual Code Writing

I certify that:

- **100% of the code** was written by me individually
- I did not copy code from classmates
- I did not share my code with classmates
- Any code that looks similar to others is due to:
  - Following official Flutter documentation
  - Using standard Flutter patterns and conventions
  - Implementing common solutions to common problems

### Group Study vs Individual Work

**What we did together**:
- Watched Flutter tutorial videos together
- Discussed concepts from lectures
- Helped each other understand error messages (conceptually)
- Shared resources and documentation links

**What I did alone**:
- Wrote all code in my repository
- Designed my app's architecture
- Implemented all features
- Debugged my own code
- Made all technical decisions

---

## Code Originality Checklist

I confirm that:

- [ ] I understand every line of code in this project
- [ ] I can explain the purpose and functionality of any code segment
- [ ] I can modify and extend the code independently
- [ ] All AI-generated code was reviewed, understood, and customized
- [ ] All third-party code is properly attributed
- [ ] No code was copied from peers without attribution
- [ ] All similar code across submissions is due to standard practices, not copying
- [ ] I am prepared to answer questions about my implementation
- [ ] I completed this project within the allowed timeframe
- [ ] I did not receive unauthorized assistance

---

## Instructor Declaration

**I understand that**:

1. This project will be checked for plagiarism using automated tools
2. My code may be compared with other submissions
3. I may be called for a viva/oral examination to verify my understanding
4. Violation of academic integrity will result in serious consequences
5. Partial or complete project failure may occur if plagiarism is detected

---

## Additional Notes

### Learning Outcomes

Through this project, I have learned:

1. **Technical Skills**:
   - Flutter widget composition and state management
   - Google Maps API integration
   - Form validation and error handling
   - Image handling in Flutter applications
   - [Add bonus features if implemented]

2. **Problem-Solving**:
   - Debugging complex Flutter errors
   - Designing efficient data structures
   - Implementing user-friendly interfaces
   - Managing asynchronous operations

3. **Best Practices**:
   - Code organization and architecture
   - Git version control workflows
   - Documentation standards
   - Testing methodologies

### Challenges Overcome

The main challenges I faced and overcame independently:

1. **[Challenge 1]**: [Describe specific challenge]
   - How I solved it: [Your solution]
   - What I learned: [Key takeaway]

2. **[Challenge 2]**: [Describe specific challenge]
   - How I solved it: [Your solution]
   - What I learned: [Key takeaway]

3. **[Challenge 3]**: [Describe specific challenge]
   - How I solved it: [Your solution]
   - What I learned: [Key takeaway]

---

## Final Statement

I affirm that all information provided in this academic integrity statement is true and accurate to the best of my knowledge. I take full responsibility for the content of my submission and understand the consequences of academic dishonesty.

```
Student Signature: _________________________________

Date: _____________________________________________
```

---

## Instructor Use Only

**Reviewed by**: _____________________________

**Date**: ____________________________________

**Integrity Verification**: [ ] Pass  [ ] Fail  [ ] Requires Viva

**Comments**:
```
_________________________________________________________________

_________________________________________________________________

_________________________________________________________________
```

---

**Last Updated**: December 2025
**Course**: CSE489 - Mobile Application Development
**Institution**: [Your University Name]
