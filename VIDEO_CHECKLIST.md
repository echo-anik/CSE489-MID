# Demo Video Preparation Guide

## Quick Reference
- **Maximum Duration**: 7 minutes
- **Minimum Quality**: 720p (1280x720)
- **Format**: MP4 or unlisted YouTube link
- **Platform**: Any screen recording software

---

## Table of Contents
1. [Video Requirements](#video-requirements)
2. [Content Checklist](#content-checklist)
3. [Recording Script Template](#recording-script-template)
4. [Technical Setup](#technical-setup)
5. [Presentation Tips](#presentation-tips)
6. [Submission Guidelines](#submission-guidelines)

---

## Video Requirements

### Duration
- **Maximum**: 7 minutes (strictly enforced)
- **Recommended**: 6-6.5 minutes (allows buffer for editing)
- **Minimum**: 5 minutes (to show all features adequately)

**Time Breakdown Suggestion**:
```
Introduction:           30 seconds
Feature Demos:          4-5 minutes
Code Walkthrough:       1-2 minutes
Challenges/Learning:    1 minute
Conclusion:             30 seconds
Total:                  ~7 minutes
```

### Format and Quality

#### Video Format
- **Preferred**: MP4 (H.264 codec)
- **Alternative**: MOV, AVI, MKV
- **Container**: MP4 recommended for best compatibility

#### Resolution
- **Minimum**: 720p (1280x720)
- **Recommended**: 1080p (1920x1080)
- **Aspect Ratio**: 16:9 (standard widescreen)

#### Frame Rate
- **Minimum**: 24 fps
- **Recommended**: 30 fps or 60 fps
- **Note**: Higher frame rates show smoother app interactions

#### File Size
- **Maximum**: Check your submission platform limits
- **Recommended**: Under 500 MB for easy upload
- **Compression**: Use H.264 codec for good quality at reasonable file size

### Submission Methods

#### Option 1: YouTube (Recommended)
- Upload as **unlisted** video (not private, not public)
- Benefits:
  - No file size limits
  - Easy to share
  - Accessible across devices
  - Supports high quality
- Submit the unlisted link

#### Option 2: Direct Upload
- Upload MP4 file to course submission portal
- Ensure file is within size limits
- Test file plays correctly before submitting

#### Option 3: Cloud Storage
- Google Drive, Dropbox, OneDrive
- Set sharing permissions to "Anyone with the link can view"
- Ensure video plays in browser without download

---

## Content Checklist

### Required Features Demonstration

#### 1. Map View with Markers
- [ ] Show map loading successfully
- [ ] Display multiple landmarks with custom markers
- [ ] Demonstrate map navigation (zoom, pan)
- [ ] Show marker tap interaction
- [ ] Display marker clustering (if implemented)
- [ ] Demonstrate current location marker (if implemented)

**Demo Points** (1 minute):
- Open app to map view
- Point out at least 3-4 landmarks on map
- Zoom in/out to show map responsiveness
- Pan across different areas
- Tap on a marker to trigger bottom sheet

#### 2. Bottom Sheet Display
- [ ] Show bottom sheet appearing on marker tap
- [ ] Display all landmark information clearly:
  - [ ] Landmark name
  - [ ] Description
  - [ ] Image (if available)
  - [ ] Location coordinates
  - [ ] Created date (if shown)
- [ ] Demonstrate bottom sheet interaction (expand/collapse)
- [ ] Show smooth animations

**Demo Points** (30 seconds):
- Tap marker to open bottom sheet
- Scroll through information if needed
- Highlight key information displayed
- Show close/dismiss animation

#### 3. List View
- [ ] Navigate to list view screen
- [ ] Show all landmarks in list format
- [ ] Display proper information for each item:
  - [ ] Name
  - [ ] Thumbnail image
  - [ ] Brief description or location
- [ ] Demonstrate smooth scrolling
- [ ] Show empty state (if no landmarks exist)

**Demo Points** (45 seconds):
- Navigate from map to list view
- Scroll through landmark list
- Point out information displayed for each landmark
- Return to map view

#### 4. Swipe Actions
- [ ] Demonstrate swipe-to-edit gesture
- [ ] Show edit action button/icon
- [ ] Demonstrate swipe-to-delete gesture
- [ ] Show delete action button/icon
- [ ] Show smooth swipe animations

**Demo Points** (30 seconds):
- Swipe a landmark item from right to left
- Show edit and delete buttons appearing
- Explain each action's purpose
- Return to normal state

#### 5. Add New Landmark
- [ ] Navigate to add landmark screen/form
- [ ] Fill in all required fields:
  - [ ] Name
  - [ ] Description
  - [ ] Location (coordinates or map selection)
  - [ ] Image (optional)
- [ ] Demonstrate image picker functionality
- [ ] Show form validation (try submitting empty form)
- [ ] Submit valid form
- [ ] Verify landmark appears on map and list

**Demo Points** (1.5 minutes):
- Tap "Add Landmark" button
- Show form with all fields
- Demonstrate image picker (camera or gallery)
- Fill in sample data:
  - Name: "Central Park"
  - Description: "Beautiful park in the city center"
  - Select location on map or enter coordinates
  - Add an image
- Submit form
- Show success message
- Navigate back to verify new landmark appears

#### 6. Edit Existing Landmark
- [ ] Select a landmark to edit (via swipe action or tap)
- [ ] Show pre-filled form with existing data
- [ ] Modify at least one field
- [ ] Change image (optional)
- [ ] Save changes
- [ ] Verify updates appear on map and list

**Demo Points** (1 minute):
- Use swipe-to-edit or tap landmark
- Show form pre-filled with existing data
- Change description or name
- Update image (optional)
- Save changes
- Verify landmark updated in map and list views

#### 7. Delete Landmark
- [ ] Select a landmark to delete (via swipe action)
- [ ] Show confirmation dialog
- [ ] Demonstrate cancel action
- [ ] Show confirmation dialog again
- [ ] Confirm deletion
- [ ] Verify landmark removed from map and list

**Demo Points** (45 seconds):
- Swipe landmark to reveal delete button
- Tap delete
- Show confirmation dialog: "Are you sure you want to delete?"
- Cancel first time
- Delete again and confirm
- Show landmark removed from both views

#### 8. Error Handling Demonstration
- [ ] Show error when submitting invalid form data
- [ ] Demonstrate validation messages:
  - [ ] Empty name field
  - [ ] Empty description field
  - [ ] Invalid coordinates (if applicable)
- [ ] Show network error handling (if applicable)
- [ ] Show permission denial handling (location, camera, gallery)
- [ ] Demonstrate graceful error recovery

**Demo Points** (45 seconds):
- Try to submit empty add landmark form
- Show validation error messages
- Fill in invalid data (if applicable)
- Show how app handles errors gracefully
- Demonstrate proper error messages to user

#### 9. Offline Caching (BONUS)
- [ ] Show app working without internet
- [ ] Demonstrate data persistence
- [ ] Show landmarks loading from local database
- [ ] Explain SQLite integration
- [ ] Show sync when internet returns (if implemented)

**Demo Points** (30 seconds):
- Turn off WiFi/mobile data
- Close and reopen app
- Show landmarks still visible
- Explain offline functionality

#### 10. User Authentication (BONUS)
- [ ] Show login screen
- [ ] Demonstrate sign up process
- [ ] Show successful login
- [ ] Demonstrate logout
- [ ] Show session persistence
- [ ] Explain Firebase integration

**Demo Points** (45 seconds):
- Show login screen
- Login with existing account or create new one
- Show authenticated home screen
- Demonstrate logout
- Show login screen again

### Code Structure Walkthrough

#### 11. File Structure Explanation
- [ ] Open project in IDE (VS Code, Android Studio)
- [ ] Show main project directory structure
- [ ] Explain organization:
  - [ ] `lib/` directory
  - [ ] `models/` folder
  - [ ] `screens/` or `views/` folder
  - [ ] `services/` folder
  - [ ] `providers/` or `state/` folder
  - [ ] `widgets/` folder
  - [ ] `utils/` folder
  - [ ] `main.dart` file
- [ ] Briefly describe each folder's purpose

**Demo Points** (45 seconds):
- Show expanded project tree
- Explain: "models folder contains data models like Landmark"
- Explain: "screens folder has MapView, ListView, FormScreen"
- Explain: "services folder manages data operations"
- Explain: "providers folder handles state management"

#### 12. Code Walkthrough
- [ ] Open and briefly show key files:
  - [ ] `main.dart` - app entry point
  - [ ] Landmark model file
  - [ ] Map view screen file
  - [ ] List view screen file
  - [ ] Add/Edit form file
  - [ ] Service layer file (if separate)
  - [ ] State management file
- [ ] Explain which file handles which screen
- [ ] Point out key functions or methods
- [ ] Show state management implementation

**Demo Points** (1 minute):
- Open `main.dart`: "This is the entry point, sets up routing and providers"
- Open `landmark.dart`: "This model defines landmark data structure"
- Open `map_view.dart`: "This file renders the map screen with markers"
- Open `list_view.dart`: "This shows landmarks in list format with swipe actions"
- Open `landmark_form.dart`: "This handles add and edit functionality"
- Open `landmark_service.dart`: "This manages CRUD operations"
- Open `landmark_provider.dart`: "This handles state management using Provider"

---

## Recording Script Template

### Introduction (30 seconds)

```
"Hello! My name is [Your Name], and I'm presenting my Flutter Landmark Management application for CSE489 Mobile Application Development.

This app allows users to:
- View landmarks on an interactive map
- Add, edit, and delete landmarks
- Upload images for each landmark
- Switch between map and list views
- [Mention bonus features if implemented]

Let me demonstrate all the features."
```

### Feature Demonstrations (4-5 minutes)

#### Map View (1 minute)

```
"Starting with the map view - this is the main screen of the app.

As you can see, I have several landmarks displayed with custom markers.
[Point to markers on screen]

I can zoom in and out to see different areas.
[Demonstrate zoom]

The map is interactive and responsive.
[Pan around the map]

When I tap on a marker...
[Tap marker]

...a bottom sheet appears showing the landmark details including name, description, and image."
[Show bottom sheet content]
```

#### List View (45 seconds)

```
"Now let me switch to the list view by tapping this icon.
[Navigate to list view]

Here you can see all landmarks in a scrollable list format. Each item shows:
- The landmark name
- A thumbnail image
- Location information

[Scroll through list]

This view makes it easy to browse all landmarks at once. Now let me show you the swipe actions."
```

#### Swipe Actions (30 seconds)

```
"If I swipe a landmark item from right to left...
[Demonstrate swipe]

...you can see edit and delete action buttons appear.
[Point to buttons]

The edit button opens the landmark for editing, and the delete button removes it with a confirmation dialog.
[Swipe back to hide buttons]

This provides quick access to modify or remove landmarks."
```

#### Add New Landmark (1.5 minutes)

```
"Let me add a new landmark by tapping the add button.
[Tap add button]

This opens a form where I can enter all the landmark information.

First, I'll enter a name: 'City Museum'
[Type in name field]

Next, a description: 'Historical museum featuring local artifacts'
[Type in description field]

Now I'll add an image by tapping the image picker button.
[Tap image picker]

I can choose from the gallery or take a new photo. I'll select from gallery.
[Select image]

The image appears in the preview.
[Show image preview]

For the location, I can either enter coordinates manually or select a point on the map. I'll select on the map.
[Show map selection if implemented]

Let me first demonstrate validation by trying to submit without filling required fields.
[Tap submit with empty form]

You can see validation errors appear for required fields.
[Show error messages]

Now I'll fill in all the information and submit.
[Fill form and submit]

The landmark is successfully added!
[Show success message]

Let me navigate back to the map to verify it appears.
[Navigate to map]

There it is - our new City Museum landmark!
[Point to new marker]
```

#### Edit Landmark (1 minute)

```
"Now let me edit an existing landmark. I'll go to the list view and swipe to reveal the edit button.
[Navigate to list, swipe landmark]

Tapping edit opens the form pre-filled with the current landmark data.
[Tap edit, show pre-filled form]

I'll update the description to add more information.
[Modify description]

I can also change the image if needed.
[Optionally change image]

Now I'll save the changes.
[Tap save]

Perfect! The landmark is updated. Let me verify in the map view.
[Navigate to map, tap marker, show updated info]

As you can see, the changes are reflected everywhere in the app."
```

#### Delete Landmark (45 seconds)

```
"To delete a landmark, I'll swipe to reveal the delete button.
[Swipe landmark]

When I tap delete...
[Tap delete]

...a confirmation dialog appears asking 'Are you sure you want to delete this landmark?'

This prevents accidental deletions. Let me cancel first.
[Tap cancel]

Now I'll delete it again and confirm.
[Swipe, delete, confirm]

The landmark is removed from the list.
[Show updated list]

And if I check the map view...
[Navigate to map]

...it's no longer there. The deletion is reflected across all views."
```

#### Error Handling (45 seconds)

```
"Let me demonstrate the app's error handling.

If I try to submit a form with invalid data...
[Show form with errors]

...clear validation messages appear telling me exactly what's wrong.
[Point to error messages]

The app handles various error scenarios gracefully:
- Form validation errors
- Missing required fields
- Invalid data formats
- [Mention other error handling implemented]

This ensures a smooth user experience even when things go wrong."
```

#### Bonus Features (if implemented) (1 minute)

```
"I've also implemented some bonus features:

[For Offline Caching:]
'The app uses SQLite for offline data persistence. Let me turn off the internet...
[Disable WiFi]

Close and reopen the app...
[Close and reopen]

And you can see all landmarks are still available because they're stored locally.'

[For Authentication:]
'The app includes Firebase authentication. Here's the login screen...
[Show login]

Users can sign up, log in, and their session persists.
[Demonstrate login]

Each user has their own set of landmarks.'
```

### Code Structure Explanation (1-2 minutes)

```
"Now let me show you the code structure.
[Open IDE, show project tree]

The project follows a clean architecture pattern:

In the 'lib' directory:
- The 'models' folder contains my Landmark model which defines the data structure
[Open landmark.dart briefly]

- The 'screens' folder has all the UI screens:
  - map_view.dart for the map screen
  - list_view.dart for the list screen
  - landmark_form.dart for add and edit functionality
[Show files in folder]

- The 'services' folder contains landmark_service.dart which handles all CRUD operations
[Show service file]

- The 'providers' folder has landmark_provider.dart for state management using the Provider pattern
[Show provider file]

- The 'widgets' folder contains reusable custom widgets
[Show widgets folder]

- And main.dart is the entry point that sets up the app, routing, and providers
[Show main.dart]

This organization makes the code maintainable and follows Flutter best practices."
```

### Challenges and Learnings (1 minute)

```
"During development, I faced several interesting challenges:

1. Synchronizing map markers with the landmark data was tricky. I solved this by implementing a listener pattern with Provider that automatically updates markers when data changes.

2. Handling image storage efficiently required creating a custom caching system with local file storage.

3. Form validation for geographic coordinates needed custom validators to ensure data integrity.

These challenges taught me a lot about:
- State management in Flutter
- Working with asynchronous operations
- Integrating third-party APIs like Google Maps
- Building user-friendly mobile interfaces

Overall, this project significantly improved my Flutter development skills and understanding of mobile app architecture."
```

### Conclusion (30 seconds)

```
"To summarize, this Flutter Landmark Management app demonstrates:
- Interactive map view with custom markers
- Complete CRUD functionality
- Image handling
- Form validation and error handling
- Clean code architecture
- [Bonus features if implemented]

All features work smoothly together to provide an excellent user experience.

Thank you for watching!

[Show your name and student ID on screen]

I'm happy to answer any questions about the implementation."
```

---

## Technical Setup

### Recording Tools

#### Windows
1. **OBS Studio** (Free, Open Source)
   - Download: https://obsproject.com/
   - Best for: High-quality recordings with customization
   - Settings: 1080p, 30fps, MP4 output

2. **ShareX** (Free)
   - Download: https://getsharex.com/
   - Best for: Quick screen recordings
   - Built-in editor for annotations

3. **Windows Game Bar** (Built-in)
   - Shortcut: Windows + G
   - Best for: Quick recordings without installation
   - Limited editing options

#### macOS
1. **QuickTime Player** (Built-in)
   - Best for: Simple, high-quality recordings
   - File > New Screen Recording

2. **OBS Studio** (Free)
   - Same as Windows version

3. **ScreenFlow** (Paid)
   - Best for: Professional editing capabilities
   - Built-in video editor

#### Cross-Platform
1. **Zoom** (Free tier available)
   - Start meeting, share screen, record
   - Easy to use, good quality

2. **Loom** (Free tier available)
   - Browser-based or desktop app
   - Easy sharing options

### Screen Resolution Settings

#### For Android Emulator

```bash
# Recommended emulator settings
Device: Pixel 4 or Pixel 5
Resolution: 1080 x 2280 (FHD+)
Density: 440 dpi
```

**In Android Studio:**
1. AVD Manager > Edit device
2. Set resolution to 1080 x 2280
3. Ensure Graphics is set to "Hardware - GLES 2.0"

#### For iOS Simulator

```bash
# Recommended simulator
Device: iPhone 12 or iPhone 13
Resolution: 1170 x 2532
Scale: 50% or 75% to fit screen
```

**In Xcode:**
1. Window > Scale > 50%
2. Ensures simulator fits on screen during recording

#### Recording Resolution

**Option 1: Full Screen** (Recommended)
- Record entire emulator/simulator window
- Show app in context
- Resolution: 1920x1080 (1080p)

**Option 2: Focused View**
- Record only the device screen
- Crop out unnecessary toolbars
- Resolution: 1080x1920 (portrait) or scale down

### Audio Quality Tips

#### Microphone Setup
1. **Use a good microphone**
   - Built-in laptop mic is acceptable
   - External USB mic is better (Blue Yeti, Samson, etc.)
   - Headset mic works well

2. **Recording environment**
   - Choose quiet room
   - Close windows to reduce outside noise
   - Turn off fans, AC during recording
   - Use soft materials to reduce echo (curtains, carpet)

3. **Audio settings**
   - Sample rate: 44.1 kHz or 48 kHz
   - Bitrate: 128 kbps minimum, 192 kbps recommended
   - Format: AAC or MP3

4. **Recording tips**
   - Do a test recording first
   - Speak clearly and at moderate pace
   - Maintain consistent distance from mic
   - Avoid "um," "uh," filler words

#### Audio Editing
- Remove background noise (Audacity is free)
- Normalize volume levels
- Add gentle fade in/out
- Remove long pauses

### Video Recording Settings

#### OBS Studio Configuration

```
Settings > Output:
- Output Mode: Simple
- Video Bitrate: 6000-10000 Kbps
- Encoder: x264
- Audio Bitrate: 192 Kbps

Settings > Video:
- Base Resolution: 1920x1080
- Output Resolution: 1920x1080
- FPS: 30

Settings > Advanced:
- Recording Format: MP4
```

#### Export Settings

**For Direct Upload:**
- Format: MP4
- Codec: H.264
- Resolution: 1920x1080
- Frame rate: 30 fps
- Bitrate: 6000-8000 Kbps

**For YouTube:**
- Same as above
- YouTube will re-encode, so prioritize quality

### YouTube Upload Instructions

#### Step-by-Step

1. **Go to YouTube Studio**
   - Visit: https://studio.youtube.com
   - Sign in with your Google account

2. **Upload Video**
   - Click "CREATE" button (top right)
   - Select "Upload videos"
   - Drag and drop your MP4 file or select it

3. **Video Details**
   - Title: "CSE489 Mid Project - Landmark Management App - [Your Name]"
   - Description:
     ```
     Flutter Landmark Management Application
     Course: CSE489 - Mobile Application Development
     Student: [Your Name]
     ID: [Your Student ID]

     Features demonstrated:
     - Interactive map view with markers
     - List view with swipe actions
     - Add, edit, delete landmarks
     - Image upload functionality
     - Form validation and error handling
     - [Bonus features if applicable]
     ```
   - Thumbnail: Create custom thumbnail with app logo or screenshot

4. **Visibility Settings**
   - **IMPORTANT**: Select "Unlisted"
   - NOT "Private" (instructor won't be able to view)
   - NOT "Public" (to maintain academic privacy)
   - "Unlisted" means anyone with the link can view

5. **Advanced Settings (Optional)**
   - Category: Education
   - Comments: Disabled
   - Age restriction: No

6. **Publish**
   - Click "NEXT" through all screens
   - Click "PUBLISH"
   - Wait for processing to complete

7. **Get Link**
   - Copy the video URL
   - Format: https://youtu.be/[VIDEO_ID]
   - This is what you submit

8. **Test Link**
   - Open link in incognito/private browser
   - Verify video plays correctly
   - Ensure quality is good

---

## Presentation Tips

### Clear Narration

#### Speaking Guidelines
1. **Pace**
   - Speak at moderate pace (not too fast, not too slow)
   - Pause between sections for clarity
   - Don't rush through features

2. **Clarity**
   - Articulate words clearly
   - Use professional language
   - Avoid slang or casual speech

3. **Structure**
   - Introduce each feature before demonstrating
   - Explain what you're doing as you do it
   - Summarize after each major section

4. **Confidence**
   - Speak confidently (you built this!)
   - Sound enthusiastic about your work
   - Avoid apologetic language

#### Voice Quality
- **Volume**: Speak loud enough to be heard clearly
- **Tone**: Professional but friendly
- **Energy**: Maintain energy throughout (don't trail off at end)
- **Consistency**: Keep volume and pace consistent

### Highlight Important Features

#### Visual Highlighting Techniques

1. **Mouse/Cursor Movement**
   - Move slowly and deliberately
   - Circle or hover over important elements
   - Don't make erratic movements

2. **Annotation Tools** (if available)
   - Use arrows to point to features
   - Add text labels for clarity
   - Highlight areas with shapes

3. **Verbal Highlighting**
   - "Notice how..."
   - "As you can see here..."
   - "The important part is..."
   - "Pay attention to..."

#### What to Emphasize

- **Custom implementations** (things you built uniquely)
- **Smooth animations and transitions**
- **Error handling** (show the app doesn't crash)
- **User-friendly messages**
- **Responsive UI**
- **Code organization**

### Show Smooth Navigation

#### Navigation Best Practices

1. **Deliberate Movements**
   - Don't rush between screens
   - Allow animations to complete
   - Give viewers time to see each screen

2. **Demonstrate Flow**
   - Show natural user journey
   - Explain why you navigate where
   - Demonstrate back button functionality

3. **Avoid Confusion**
   - Don't jump randomly between screens
   - Follow logical progression
   - Return to main view between major sections

### Mention File Names During Code Walkthrough

#### Effective Code Presentation

1. **File Name Announcement**
   - Always say the file name before showing it
   - Example: "Now let's look at landmark_model.dart..."
   - Show file path briefly if helpful

2. **Code Explanation**
   - Don't read code line by line
   - Explain the purpose and key concepts
   - Point out important methods or functions
   - Example: "This class defines the Landmark model with all properties like name, description, coordinates, and provides methods for JSON serialization"

3. **Quick Walkthrough**
   - Don't spend too long on code
   - Hit the highlights
   - Focus on architecture and organization

4. **Screen Visibility**
   - Zoom in if text is small
   - Ensure code is readable in recording
   - Use good IDE theme (dark or light - whatever is readable)

### Demo Flow Tips

#### Before Recording
- [ ] Close unnecessary applications
- [ ] Hide desktop clutter
- [ ] Turn off notifications
- [ ] Prepare emulator/simulator in advance
- [ ] Have app running and ready
- [ ] Practice run-through at least twice
- [ ] Time yourself to ensure under 7 minutes

#### During Recording
- [ ] Start with clean state (or known data)
- [ ] Don't demonstrate bugs or errors (unless showing error handling)
- [ ] Have sample data ready to input
- [ ] Keep mouse movements smooth
- [ ] Avoid clicking randomly
- [ ] If you make a mistake, pause and restart that section

#### After Recording
- [ ] Watch entire video
- [ ] Check audio quality
- [ ] Verify all features shown
- [ ] Ensure timing is under 7 minutes
- [ ] Confirm video quality is 720p+
- [ ] Test playback on different device

---

## Submission Guidelines

### Pre-Submission Checklist

#### Video Content
- [ ] All required features demonstrated (map, list, add, edit, delete)
- [ ] Bottom sheet interaction shown
- [ ] Swipe actions demonstrated
- [ ] Form validation shown
- [ ] Error handling demonstrated
- [ ] Code structure explained
- [ ] File walkthrough included
- [ ] Bonus features shown (if implemented)

#### Technical Requirements
- [ ] Video duration ≤ 7 minutes
- [ ] Resolution ≥ 720p
- [ ] Audio is clear and audible
- [ ] Format is MP4 (or YouTube link)
- [ ] Video plays without errors
- [ ] File size is acceptable for submission platform

#### Professionalism
- [ ] Clear introduction with name and ID
- [ ] Professional narration throughout
- [ ] No inappropriate content in background
- [ ] Conclusion summarizes the project
- [ ] Contact information shown (if required)

### Submission Process

#### Step 1: Final Review
1. Watch your video completely
2. Verify all checklist items
3. Check video on different device
4. Confirm audio quality

#### Step 2: Prepare Submission

**If submitting file directly:**
```
Filename format: CSE489_Mid_[YourName]_[StudentID].mp4
Example: CSE489_Mid_JohnDoe_2019123456.mp4
```

**If submitting YouTube link:**
```
Create a text file with the link:
Filename: CSE489_Mid_[YourName]_[StudentID]_Link.txt

Content:
Student Name: John Doe
Student ID: 2019123456
Video Link: https://youtu.be/xxxxxxxxx
```

#### Step 3: Upload

1. Navigate to submission portal
2. Upload video file or link file
3. Verify upload completed successfully
4. Test that link/file is accessible
5. Take screenshot of successful submission

#### Step 4: Confirmation

- [ ] Received confirmation email/message
- [ ] Uploaded before deadline
- [ ] File/link is accessible to instructor
- [ ] No upload errors

### Common Issues and Solutions

#### Issue: Video too large to upload
**Solution:**
- Use YouTube unlisted upload instead
- Compress video using HandBrake (free tool)
- Reduce bitrate slightly (6000 Kbps should be acceptable)

#### Issue: Video exceeds 7 minutes
**Solution:**
- Edit and remove unnecessary parts
- Speed up certain sections (1.2x or 1.5x)
- Reduce introduction/conclusion length
- Remove redundant demonstrations

#### Issue: Audio not synced with video
**Solution:**
- Re-record
- Use video editing software to sync
- Ensure screen recorder captures audio correctly

#### Issue: Poor video quality on upload
**Solution:**
- Upload in highest quality available
- Check YouTube processing (may take time for HD)
- Ensure original recording was high quality

#### Issue: Unlisted YouTube video not accessible
**Solution:**
- Check privacy settings (must be "Unlisted")
- Ensure link is correct
- Test in incognito browser
- Share link, not video ID

---

## Additional Resources

### Video Editing Software (Optional)

#### Free Options
1. **DaVinci Resolve**
   - Professional-grade, completely free
   - Windows, macOS, Linux
   - Learning curve but powerful

2. **Shotcut**
   - Free, open-source
   - Simple interface
   - Good for basic editing

3. **iMovie** (macOS)
   - Built-in on Mac
   - Easy to use
   - Good for quick edits

#### Paid Options
1. **Adobe Premiere Pro**
   - Industry standard
   - Student pricing available
   - Full-featured

2. **Final Cut Pro** (macOS)
   - Professional Mac video editor
   - One-time purchase

3. **Camtasia**
   - Great for screen recordings
   - Built-in editor
   - Easy to use

### Thumbnail Creation Tools

- **Canva** (free): https://www.canva.com
- **Adobe Spark** (free tier): https://spark.adobe.com
- **Figma** (free): https://www.figma.com

**Thumbnail suggestions:**
- App icon + "Landmark Management"
- Screenshot of map view
- Your name and student ID
- University logo (if allowed)

### Practice Resources

#### Example Structure to Practice

Run through this flow multiple times before recording:

1. Open app (map view)
2. Show 3-4 landmarks
3. Tap marker, show bottom sheet
4. Navigate to list view
5. Scroll through list
6. Swipe one item to show actions
7. Navigate to add landmark
8. Fill form (have data ready!)
9. Submit new landmark
10. Verify it appears
11. Edit one landmark
12. Delete one landmark (with confirmation)
13. Show error handling (invalid form)
14. Show bonus features (if any)
15. Quick code walkthrough
16. Conclusion

**Time each section** to ensure you stay under 7 minutes total.

---

## Final Checklist Before Submission

### Content Verification
- [ ] Introduction includes name and student ID
- [ ] Map view fully demonstrated
- [ ] Bottom sheet shown clearly
- [ ] List view navigated
- [ ] Swipe actions demonstrated
- [ ] Add landmark shown with all steps
- [ ] Edit landmark demonstrated
- [ ] Delete landmark with confirmation shown
- [ ] Error handling explained
- [ ] Offline caching shown (if implemented)
- [ ] Authentication shown (if implemented)
- [ ] File structure explained
- [ ] Code walkthrough completed
- [ ] Challenges mentioned
- [ ] Conclusion provided

### Technical Verification
- [ ] Duration: ≤ 7 minutes
- [ ] Resolution: ≥ 720p
- [ ] Format: MP4 or YouTube unlisted
- [ ] Audio: Clear and professional
- [ ] Video: Smooth playback
- [ ] File size: Within limits
- [ ] No corrupted segments
- [ ] Tested on multiple devices

### Quality Verification
- [ ] Narration is clear and audible
- [ ] Speaking pace is appropriate
- [ ] No long awkward pauses
- [ ] Professional tone maintained
- [ ] Features highlighted effectively
- [ ] Navigation is smooth
- [ ] No errors or bugs shown (except error handling demo)
- [ ] Video quality is good
- [ ] No distracting background

### Submission Verification
- [ ] Correct file name format
- [ ] Uploaded to correct platform
- [ ] Link is accessible (if YouTube)
- [ ] Privacy set to unlisted (if YouTube)
- [ ] Submission confirmed
- [ ] Deadline met
- [ ] Backup copy saved

---

## Time Management Guide

### Suggested Timeline

**1 Week Before Deadline:**
- [ ] Complete all app features
- [ ] Test thoroughly
- [ ] Fix any bugs
- [ ] Prepare sample data for demo

**3 Days Before Deadline:**
- [ ] Write recording script
- [ ] Practice demonstration 2-3 times
- [ ] Time yourself
- [ ] Adjust script to fit 7 minutes
- [ ] Set up recording software

**2 Days Before Deadline:**
- [ ] Record first attempt
- [ ] Watch and critique
- [ ] Note improvements needed
- [ ] Practice again
- [ ] Record final version

**1 Day Before Deadline:**
- [ ] Edit video if needed
- [ ] Upload to YouTube (if using)
- [ ] Verify upload quality
- [ ] Test link accessibility
- [ ] Prepare submission file

**Deadline Day:**
- [ ] Final review
- [ ] Submit early (don't wait until last minute!)
- [ ] Confirm submission received
- [ ] Keep backup copy

---

**Good luck with your demo video!**

Remember: The video should showcase your hard work and technical skills. Be confident, be clear, and demonstrate everything you've built. You've got this!

---

**Last Updated**: December 2025
**Course**: CSE489 - Mobile Application Development
**Project**: Flutter Landmark Management App
