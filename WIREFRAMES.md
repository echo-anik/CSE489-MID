# Wireframes - Landmark Management App

## Table of Contents
1. [Overview](#overview)
2. [Design System](#design-system)
3. [Screen Wireframes](#screen-wireframes)
   - [Splash Screen](#1-splash-screen)
   - [Map View Screen](#2-map-view-screen-overview-tab)
   - [List View Screen](#3-list-view-screen-records-tab)
   - [New Entry Screen](#4-new-entry-screen-form)
   - [Landmark Detail/Edit Screen](#5-landmark-detailedit-screen)
   - [Bottom Navigation Bar](#6-bottom-navigation-bar)
4. [UI Components](#ui-components)
5. [Dialogs and Snackbars](#dialogs-and-snackbars)
6. [Navigation Flow](#navigation-flow)
7. [Interaction Patterns](#interaction-patterns)

---

## Overview

**App Name:** Landmark Manager
**Platform:** Flutter (Android/iOS)
**Primary Color Scheme:** Blue/Teal with white backgrounds
**Default Location:** Bangladesh (23.6850°N, 90.3563°E)

**Core Features:**
- Interactive map with custom markers
- List view with swipe gestures
- Form-based entry creation
- Image capture/selection
- GPS auto-detection
- CRUD operations for landmarks

---

## Design System

### Color Palette
- **Primary:** `#2196F3` (Blue)
- **Primary Dark:** `#1976D2`
- **Accent:** `#00BCD4` (Cyan)
- **Background:** `#FFFFFF`
- **Surface:** `#F5F5F5`
- **Error:** `#F44336`
- **Success:** `#4CAF50`
- **Text Primary:** `#212121`
- **Text Secondary:** `#757575`

### Typography
- **Heading 1:** 24sp, Bold
- **Heading 2:** 20sp, Semi-Bold
- **Body:** 16sp, Regular
- **Caption:** 14sp, Regular
- **Button:** 16sp, Medium

### Spacing
- **XS:** 4dp
- **S:** 8dp
- **M:** 16dp
- **L:** 24dp
- **XL:** 32dp

---

## Screen Wireframes

### 1. Splash Screen

**Purpose:** Initial loading screen with app branding

```
┌─────────────────────────────────────┐
│                                     │
│                                     │
│                                     │
│            ┌─────────┐              │
│            │         │              │
│            │  LOGO   │              │
│            │  Icon   │              │
│            │         │              │
│            └─────────┘              │
│                                     │
│         LANDMARK MANAGER            │
│                                     │
│                                     │
│         ○ ○ ○ Loading...            │
│                                     │
│                                     │
│                                     │
│         v1.0.0                      │
│                                     │
└─────────────────────────────────────┘
```

**Components:**
- App logo/icon (centered, 120x120dp)
- App name text (Heading 1)
- Loading indicator (circular progress)
- Version number (bottom, Caption)

**Duration:** 2-3 seconds or until data loads

**Navigation:** Auto-transitions to Map View Screen

---

### 2. Map View Screen (Overview Tab)

**Purpose:** Display all landmarks on an interactive map

```
┌─────────────────────────────────────┐
│  ☰  Landmark Manager        [🔍][⚙]│ ← AppBar
├─────────────────────────────────────┤
│                                     │
│    ┌──────────────────────────┐    │
│    │      📍        📍         │    │
│    │                           │    │
│    │   📍    BANGLADESH   📍   │    │ ← Map Area
│    │                           │    │
│    │        📍      📍         │    │
│    │                           │    │
│    └──────────────────────────┘    │
│                                     │
│  [📍 My Location]  [+ Zoom] [-Zoom]│ ← Map Controls
│                                     │
├─────────────────────────────────────┤
│ When marker tapped:                 │
│ ┌─────────────────────────────────┐ │
│ │ ╔═══════════════════════════════╗│ │
│ │ ║  ┌──────┐  National Monument ║│ │ ← Bottom Sheet
│ │ ║  │      │  Savar, Dhaka       ║│ │
│ │ ║  │ IMG  │  23.7805°N          ║│ │
│ │ ║  │      │  90.2786°E          ║│ │
│ │ ║  └──────┘                     ║│ │
│ │ ║  [✏ Edit] [🗑 Delete] [→ View]║│ │
│ │ ╚═══════════════════════════════╝│ │
│ └─────────────────────────────────┘ │
├─────────────────────────────────────┤
│  [🗺 Overview] [📋 Records] [➕ New]│ ← Bottom Nav
└─────────────────────────────────────┘
```

#### Layout Structure

**AppBar (56dp height):**
- Hamburger menu icon (left)
- Title: "Landmark Manager" (center/left)
- Search icon (right, -16dp)
- Settings icon (right, -8dp)

**Map Container (fills remaining space):**
- Google Maps/OSM implementation
- Default center: 23.6850°N, 90.3563°E
- Default zoom: 7
- Custom marker icons (red pin with white center)
- Clustering enabled for multiple nearby markers

**Map Controls (Floating, bottom-right):**
- My Location button (FAB mini, 40dp)
- Zoom In button (FAB mini, 40dp)
- Zoom Out button (FAB mini, 40dp)
- Vertical stack with 8dp spacing

**Bottom Sheet (slides up on marker tap):**
- Handle bar (centered, 4dp height, 32dp width)
- Peek height: 200dp
- Expanded height: 400dp
- Content:
  - Thumbnail image (80x80dp, rounded corners 8dp)
  - Title (Heading 2, max 2 lines)
  - Location text (Body, gray)
  - Coordinates (Caption, gray)
  - Action buttons row:
    - Edit button (outlined, left)
    - Delete button (outlined, center)
    - View Details button (filled, right)

**User Interactions:**
- Tap marker → Show bottom sheet
- Drag map → Pan view
- Pinch → Zoom in/out
- Tap My Location → Center on user
- Tap Edit → Navigate to Edit screen
- Tap Delete → Show confirmation dialog
- Tap View → Navigate to Detail screen
- Drag bottom sheet → Expand/collapse

---

### 3. List View Screen (Records Tab)

**Purpose:** Display landmarks in a scrollable list with swipe actions

```
┌─────────────────────────────────────┐
│  Landmark Records           [🔍][⚙] │ ← AppBar
├─────────────────────────────────────┤
│  📊 Total: 12 landmarks             │ ← Stats Bar
├─────────────────────────────────────┤
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ ┌────┐  National Monument      │ │ ← Card 1
│ │ │    │  Savar, Dhaka            │ │
│ │ │IMG │  23.7805°N, 90.2786°E   │ │
│ │ └────┘  Added: 2025-12-01      →│ │
│ └─────────────────────────────────┘ │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ ┌────┐  Ahsan Manzil           │ │ ← Card 2
│ │ │    │  Old Dhaka               │ │
│ │ │IMG │  23.7085°N, 90.4066°E   │ │
│ │ └────┘  Added: 2025-11-28      →│ │
│ └─────────────────────────────────┘ │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ ┌────┐  Lalbagh Fort           │ │ ← Card 3
│ │ │    │  Old Dhaka               │ │
│ │ │IMG │  23.7197°N, 90.3876°E   │ │
│ │ └────┘  Added: 2025-11-25      →│ │
│ └─────────────────────────────────┘ │
│                                     │
│  ↓ Scroll for more...               │
│                                     │
├─────────────────────────────────────┤
│  [🗺 Overview] [📋 Records] [➕ New]│ ← Bottom Nav
└─────────────────────────────────────┘

SWIPE ACTIONS:
Swipe Left (Delete):
┌─────────────────────────────────────┐
│ ← ┌──────────────────────┐ [🗑 Del] │
│   │ Monument Card        │          │
│   └──────────────────────┘          │
└─────────────────────────────────────┘

Swipe Right (Edit):
┌─────────────────────────────────────┐
│ [✏ Edit] ┌──────────────────────┐ →│
│          │ Monument Card        │   │
│          └──────────────────────┘   │
└─────────────────────────────────────┘
```

#### Layout Structure

**AppBar (56dp height):**
- Title: "Landmark Records"
- Search icon (filter landmarks)
- Settings icon

**Stats Bar (48dp height):**
- Total count text with icon
- Background: Light gray (#F5F5F5)
- Optional: Sort/Filter chips

**List Container (scrollable):**
- Vertical RecyclerView/ListView
- Padding: 16dp horizontal, 8dp vertical
- Item spacing: 8dp

**Landmark Card (120dp height):**
```
Structure:
┌────────────────────────────────────┐
│ ┌──────┐                          │
│ │      │  Title (Heading 2)       │
│ │ IMG  │  Location (Body)         │
│ │ 80x  │  Coordinates (Caption)   │
│ │ 80dp │  Date (Caption, light)   │
│ └──────┘                        → │
└────────────────────────────────────┘
```

**Card Components:**
- Elevation: 2dp
- Corner radius: 8dp
- Padding: 16dp
- Image: 80x80dp, rounded 4dp
- Content: 16dp left margin from image
- Chevron icon (right, 16dp from edge)

**Swipe Gestures:**
- **Left Swipe:** Red background, delete icon
- **Right Swipe:** Blue background, edit icon
- Threshold: 30% of card width
- Animation: Spring physics

**User Interactions:**
- Tap card → Navigate to Detail screen
- Swipe left → Show delete confirmation
- Swipe right → Navigate to Edit screen
- Pull to refresh → Reload data
- Scroll → Load more (if paginated)

**Empty State:**
```
┌─────────────────────────────────────┐
│                                     │
│           ┌─────────┐               │
│           │         │               │
│           │  📍❌   │               │
│           │         │               │
│           └─────────┘               │
│                                     │
│      No landmarks yet               │
│   Tap + to add your first one!      │
│                                     │
└─────────────────────────────────────┘
```

---

### 4. New Entry Screen (Form)

**Purpose:** Create a new landmark entry with all required information

```
┌─────────────────────────────────────┐
│  ← Add New Landmark         [✓Save] │ ← AppBar
├─────────────────────────────────────┤
│  ┌─────────────────────────────┐   │
│  │ ▼ Scroll to fill all fields │   │ ← Scroll View
│  │                              │   │
│  │  ┌────────────────────────┐ │   │
│  │  │ 📷 Tap to add image    │ │   │ ← Image Picker
│  │  │                        │ │   │
│  │  │      [+ Add Photo]     │ │   │
│  │  │                        │ │   │
│  │  └────────────────────────┘ │   │
│  │                              │   │
│  │  Landmark Title *            │   │
│  │  ┌────────────────────────┐ │   │ ← Text Input
│  │  │ Enter landmark name... │ │   │
│  │  └────────────────────────┘ │   │
│  │                              │   │
│  │  Location / Address          │   │
│  │  ┌────────────────────────┐ │   │ ← Text Input
│  │  │ e.g., Savar, Dhaka...  │ │   │
│  │  └────────────────────────┘ │   │
│  │                              │   │
│  │  ┌──────────────┬─────────┐ │   │
│  │  │ Latitude *   │[📍 GPS] │ │   │ ← Number Input
│  │  │ 23.6850      │         │ │   │   + GPS Button
│  │  └──────────────┴─────────┘ │   │
│  │                              │   │
│  │  ┌──────────────┬─────────┐ │   │
│  │  │ Longitude *  │         │ │   │ ← Number Input
│  │  │ 90.3563      │         │ │   │
│  │  └──────────────┴─────────┘ │   │
│  │                              │   │
│  │  Description (Optional)      │   │
│  │  ┌────────────────────────┐ │   │ ← Text Area
│  │  │ Add details about this │ │   │
│  │  │ landmark...            │ │   │
│  │  │                        │ │   │
│  │  └────────────────────────┘ │   │
│  │                              │   │
│  │  Category (Optional)         │   │
│  │  ┌────────────────────────┐ │   │ ← Dropdown
│  │  │ Select category...   ▼ │ │   │
│  │  └────────────────────────┘ │   │
│  │                              │   │
│  │  ┌──────────────────────┐   │   │
│  │  │   ✓ Save Landmark    │   │   │ ← Primary Button
│  │  └──────────────────────┘   │   │
│  │                              │   │
│  │  ┌──────────────────────┐   │   │
│  │  │   ✗ Cancel           │   │   │ ← Secondary Button
│  │  └──────────────────────┘   │   │
│  │                              │   │
│  └─────────────────────────────┘   │
│                                     │
├─────────────────────────────────────┤
│  [🗺 Overview] [📋 Records] [➕ New]│ ← Bottom Nav
└─────────────────────────────────────┘
```

#### Layout Structure

**AppBar (56dp height):**
- Back arrow (left)
- Title: "Add New Landmark"
- Save icon (right) - Quick save action

**Form Container (scrollable):**
- SingleChildScrollView with padding: 16dp
- Field spacing: 24dp vertical

**Image Picker Section (200dp height):**
```
┌────────────────────────────────────┐
│  ┌──────────────────────────────┐ │
│  │                              │ │
│  │    📷 [Placeholder Icon]     │ │
│  │                              │ │
│  │    [+ Add Photo Button]      │ │
│  │                              │ │
│  └──────────────────────────────┘ │
│  or (with image):                 │
│  ┌──────────────────────────────┐ │
│  │  ┌────────────────────────┐  │ │
│  │  │                        │  │ │
│  │  │   Selected Image       │  │ │
│  │  │                        │  │ │
│  │  └────────────────────────┘  │ │
│  │    [✗ Remove] [🔄 Change]    │ │
│  └──────────────────────────────┘ │
└────────────────────────────────────┘
```

**States:**
- Empty: Dashed border, camera icon, "Tap to add" text
- With image: Full image preview, Remove/Change buttons
- Corner radius: 8dp
- Border: 2dp dashed gray (empty) / none (filled)

**Action Options:**
- Camera icon → Opens bottom sheet:
  - "Take Photo" (camera icon)
  - "Choose from Gallery" (gallery icon)
  - "Cancel"

**Text Input Fields:**

1. **Title Field (Required):**
   - Label: "Landmark Title *"
   - Hint: "Enter landmark name..."
   - Max length: 100 characters
   - Validation: Required, min 3 characters

2. **Location Field:**
   - Label: "Location / Address"
   - Hint: "e.g., Savar, Dhaka..."
   - Max length: 200 characters

3. **Latitude Field (Required):**
   - Label: "Latitude *"
   - Hint: "23.6850"
   - Input type: Decimal number
   - Range: -90 to 90
   - Decimal places: 6
   - Width: 70% of container
   - GPS button attached (30% width)

4. **Longitude Field (Required):**
   - Label: "Longitude *"
   - Hint: "90.3563"
   - Input type: Decimal number
   - Range: -180 to 180
   - Decimal places: 6
   - Width: 70% of container
   - GPS button grayed out (action on latitude field)

**GPS Auto-Detect Button:**
```
┌─────────────────────────┐
│  Latitude *   [📍 GPS]  │
│  23.6850      [Detect]  │
└─────────────────────────┘
```
- Position: Right side of latitude field
- Size: 48dp height, 80dp width
- Icon: Location pin
- Action: Gets current GPS coordinates
- Loading state: Shows spinner
- Error state: Shows error icon with tooltip

**GPS Button States:**
```
Idle:     [📍 GPS]
Loading:  [○ ○ ○]  ← Spinner
Success:  [✓ GPS]  ← Green check
Error:    [✗ GPS]  ← Red X
```

5. **Description Field (Optional):**
   - Label: "Description (Optional)"
   - Hint: "Add details about this landmark..."
   - Min lines: 3
   - Max lines: 6
   - Max length: 500 characters
   - Character counter shown

6. **Category Dropdown (Optional):**
   - Label: "Category (Optional)"
   - Hint: "Select category..."
   - Options:
     - Historical
     - Religious
     - Natural
     - Educational
     - Recreational
     - Other

**Action Buttons:**

1. **Save Button (Primary):**
   - Text: "Save Landmark"
   - Width: Match parent
   - Height: 48dp
   - Background: Primary color
   - Text: White
   - Enabled: Only when required fields filled
   - Disabled state: Gray background, gray text

2. **Cancel Button (Secondary):**
   - Text: "Cancel"
   - Width: Match parent
   - Height: 48dp
   - Background: Transparent
   - Border: 1dp primary color
   - Text: Primary color
   - Always enabled

**User Interactions:**
- Tap image area → Show photo source dialog
- Tap GPS button → Request location permission, get coordinates
- Type in fields → Auto-validate on blur
- Tap Save → Validate all, show errors or save and navigate back
- Tap Cancel → Show confirmation dialog if fields have content
- Scroll → Ensure focused field visible above keyboard

**Validation Messages:**
```
Error state example:
┌────────────────────────────────┐
│ Landmark Title *               │
│ ┌────────────────────────────┐ │
│ │ Ab                         │ │ ← Red border
│ └────────────────────────────┘ │
│ ⚠ Title must be at least 3    │ ← Error text
│   characters                   │
└────────────────────────────────┘
```

---

### 5. Landmark Detail/Edit Screen

**Purpose:** View full details and edit existing landmark

```
┌─────────────────────────────────────┐
│  ← Landmark Details         [✏][🗑]│ ← AppBar (View Mode)
├─────────────────────────────────────┤
│  ┌─────────────────────────────┐   │
│  │ ▼ Scroll for details        │   │
│  │                              │   │
│  │  ┌────────────────────────┐ │   │
│  │  │                        │ │   │
│  │  │   Full Size Image      │ │   │ ← Hero Image
│  │  │     (16:9 ratio)       │ │   │
│  │  │                        │ │   │
│  │  └────────────────────────┘ │   │
│  │                              │   │
│  │  National Monument           │   │ ← Title (H1)
│  │                              │   │
│  │  📍 Location                 │   │
│  │  Savar, Dhaka                │   │
│  │                              │   │
│  │  🌐 Coordinates              │   │
│  │  Lat: 23.7805°N              │   │
│  │  Lng: 90.2786°E              │   │
│  │  [📋 Copy] [🗺 Open in Maps] │   │
│  │                              │   │
│  │  📝 Description              │   │
│  │  The National Martyrs'       │   │
│  │  Memorial is a national      │   │
│  │  monument in Bangladesh...   │   │
│  │                              │   │
│  │  🏷 Category                 │   │
│  │  Historical                  │   │
│  │                              │   │
│  │  📅 Added                    │   │
│  │  December 1, 2025            │   │
│  │                              │   │
│  │  ┌──────────────────────┐   │   │
│  │  │   ✏ Edit Details     │   │   │ ← Edit Button
│  │  └──────────────────────┘   │   │
│  │                              │   │
│  └─────────────────────────────┘   │
│                                     │
├─────────────────────────────────────┤
│  [🗺 Overview] [📋 Records] [➕ New]│
└─────────────────────────────────────┘

EDIT MODE:
┌─────────────────────────────────────┐
│  ← Edit Landmark            [✓Save] │ ← AppBar (Edit Mode)
├─────────────────────────────────────┤
│  [Same form layout as New Entry]    │
│  but with pre-filled values          │
└─────────────────────────────────────┘
```

#### Layout Structure

**View Mode:**

**AppBar:**
- Back arrow
- Title: "Landmark Details"
- Edit icon (right)
- Delete icon (right)

**Content (scrollable):**
- Hero image (full width, 16:9 ratio)
- Content padding: 16dp
- Section spacing: 24dp

**Image Section:**
- Aspect ratio: 16:9
- Tap to view fullscreen
- Pinch to zoom (in fullscreen mode)

**Information Sections:**
Each section has:
- Icon (24dp, primary color)
- Label (Caption, gray)
- Value (Body, black)

1. **Title Section:**
   - Large heading (H1)
   - Top margin: 16dp

2. **Location Section:**
   - Icon: Pin
   - Address text

3. **Coordinates Section:**
   - Icon: Globe
   - Latitude line
   - Longitude line
   - Action buttons:
     - Copy coordinates (copies to clipboard)
     - Open in Maps (external map app)

4. **Description Section:**
   - Icon: Document
   - Multi-line text
   - Expandable if > 5 lines

5. **Category Section:**
   - Icon: Tag
   - Category badge with background color

6. **Metadata Section:**
   - Icon: Calendar
   - Created date
   - Last modified (if different)

**Edit Button:**
- Full width
- Primary color
- Height: 48dp
- Bottom margin: 16dp

**Edit Mode:**
- Same layout as New Entry screen
- All fields pre-populated
- AppBar shows "Edit Landmark"
- Save button in AppBar
- Cancel functionality shows unsaved changes warning

---

### 6. Bottom Navigation Bar

**Purpose:** Primary navigation between main sections

```
┌─────────────────────────────────────┐
│                                     │
│  [Screen Content Above]             │
│                                     │
├─────────────────────────────────────┤
│                                     │
│  🗺         📋          ➕          │ ← Icons
│  Overview   Records     New         │ ← Labels
│  ─────                              │ ← Active Indicator
│                                     │
└─────────────────────────────────────┘

States:

ACTIVE TAB (Overview):
┌──────────┬──────────┬──────────┐
│   🗺     │   📋    │    ➕    │
│ Overview │ Records │   New    │
│ ─────── │         │          │ ← Blue underline
│ (Blue)   │ (Gray)  │  (Gray)  │ ← Color
└──────────┴──────────┴──────────┘

INACTIVE TAB:
- Icon: Gray (#757575)
- Label: Gray (#757575)
- No indicator line
```

#### Specifications

**Container:**
- Height: 56dp
- Background: White
- Elevation: 8dp (shadow above)
- Fixed to bottom of screen

**Navigation Items:**
- Count: 3
- Width: Equal distribution (33.33% each)
- Alignment: Center (icon + label)

**Item Structure:**
```
     Icon (24dp)
       ↓
     [Icon]
     Label
     ──────  ← Only if active
```

**Tab Specifications:**

1. **Overview (Map):**
   - Icon: Map pin in circle
   - Label: "Overview"
   - Route: /map
   - Active: Blue tint

2. **Records (List):**
   - Icon: List/document icon
   - Label: "Records"
   - Route: /records
   - Active: Blue tint

3. **New (Form):**
   - Icon: Plus in circle
   - Label: "New"
   - Route: /new
   - Active: Blue tint
   - Alternative: Can be FAB overlay

**Animations:**
- Tab switch: 300ms fade
- Icon ripple on tap
- Indicator slide: 200ms ease

**Badge Support:**
```
  📋 [5]    ← Red badge with count
  Records
```
- Use for: Unsaved drafts, sync pending, etc.
- Position: Top-right of icon
- Size: 16dp diameter (min)
- Background: Red (#F44336)
- Text: White, 10sp

**Alternative Design (FAB for New):**
```
┌─────────────────────────────────────┐
│                                     │
│  🗺         📋          ( )         │
│  Overview   Records    [➕]         │ ← FAB overlaps
│  ─────                  │           │
│                         │           │
└────────────────────────────────────┘
```
- FAB: 56dp diameter
- Elevation: 6dp
- Primary color background
- White icon
- Extends above bottom nav

---

## UI Components

### Custom Marker Icon

```
   ●      ← Red circle (24dp)
   ●
  ╱ ╲     ← Pin shape
 ╱   ╲
▕     ▏
 ╲   ╱
  ╲ ╱
   ▽      ← Point
```

**Specifications:**
- Size: 32x48dp
- Color: `#F44336` (Red) with white center
- Shadow: 2dp below
- States:
  - Default: Red
  - Selected: Blue
  - Clustered: Shows number badge

### Image Placeholder

```
┌──────────────────┐
│                  │
│                  │
│   📷  [Icon]     │ ← Camera icon (48dp)
│                  │
│  No image yet    │ ← Caption text
│                  │
│                  │
└──────────────────┘
```

**Specifications:**
- Background: `#F5F5F5`
- Border: 1dp dashed `#BDBDBD`
- Icon: Gray `#9E9E9E`
- Text: Gray `#757575`
- Corner radius: 8dp

### Loading Indicator

```
Primary (Full screen):
┌─────────────────────┐
│                     │
│                     │
│     ○  ○  ○         │ ← Animated dots
│   Loading...        │
│                     │
│                     │
└─────────────────────┘

Inline (Button/Form):
[○ ○ ○] Saving...      ← Inside button

Card (Shimmer):
┌─────────────────────┐
│ ▓▓▓▓  ░░░░░░░░░░   │ ← Shimmer animation
│ ▓▓▓▓  ░░░░░░       │
│ ▓▓▓▓  ░░░░         │
└─────────────────────┘
```

### Swipe Action Indicators

```
DELETE (Left swipe):
┌────────────────┬─────────┐
│ ← Swipe left   │  🗑     │ ← Red background
│ Card content   │ Delete  │
└────────────────┴─────────┘

EDIT (Right swipe):
┌─────────┬────────────────┐
│  ✏     │ Swipe right →  │ ← Blue background
│ Edit    │ Card content   │
└─────────┴────────────────┘
```

**Specifications:**
- Background reveal on swipe
- Icon + text label
- Haptic feedback at threshold
- Spring animation on release

---

## Dialogs and Snackbars

### 1. Delete Confirmation Dialog

```
┌─────────────────────────────────┐
│                                 │
│  ⚠  Delete Landmark?            │ ← Title
│                                 │
│  Are you sure you want to       │
│  delete "National Monument"?    │ ← Content
│  This action cannot be undone.  │
│                                 │
│               [Cancel] [Delete] │ ← Actions
│                                 │
└─────────────────────────────────┘
```

**Specifications:**
- Width: 280dp (mobile) / 400dp (tablet)
- Corner radius: 8dp
- Elevation: 24dp
- Padding: 24dp
- Buttons:
  - Cancel: Text button, gray
  - Delete: Text button, red
- Icon: Warning triangle, red
- Dimmed background (scrim): 50% black

### 2. Photo Source Dialog

```
┌─────────────────────────────────┐
│  Select Photo Source            │ ← Title
├─────────────────────────────────┤
│                                 │
│  📷  Take Photo                 │ ← Option 1
│                                 │
│  🖼  Choose from Gallery        │ ← Option 2
│                                 │
│  ✗  Cancel                      │ ← Option 3
│                                 │
└─────────────────────────────────┘
```

**Specifications:**
- Bottom sheet style (slides from bottom)
- Options: 56dp height each
- Icon: 24dp, left aligned
- Text: 16sp, left margin 16dp from icon
- Ripple effect on tap

### 3. Permission Request Dialog

```
┌─────────────────────────────────┐
│  📍 Location Permission          │
│                                 │
│  This app needs access to your │
│  location to auto-detect        │
│  coordinates for landmarks.     │
│                                 │
│  [Deny] [Allow]                 │
└─────────────────────────────────┘
```

### 4. Error Dialog

```
┌─────────────────────────────────┐
│  ✗  Error                       │
│                                 │
│  Failed to save landmark:       │
│  • Check internet connection    │
│  • Verify all required fields   │
│                                 │
│                        [Retry]  │
└─────────────────────────────────┘
```

**Error Types:**
- Network error
- Validation error
- GPS unavailable
- Storage permission denied
- Image load failed

### 5. Success Snackbar

```
┌─────────────────────────────────────┐
│                                     │
│  [Screen Content]                   │
│                                     │
│ ┌─────────────────────────────────┐│
│ │ ✓ Landmark saved successfully  │││ ← Snackbar
│ │                         [UNDO] │││
│ └─────────────────────────────────┘│
└─────────────────────────────────────┘
```

**Specifications:**
- Position: Bottom (above nav bar)
- Height: 48dp (single line) / 80dp (multi-line)
- Background: `#323232` (dark gray)
- Text: White
- Duration: 4 seconds
- Action button: Accent color
- Margin: 16dp from edges
- Corner radius: 4dp

**Variants:**
```
Success: ✓ Landmark saved successfully
Info:    ℹ Syncing data...
Warning: ⚠ Location accuracy is low
Error:   ✗ Failed to delete landmark
```

### 6. GPS Loading Dialog

```
┌─────────────────────────────────┐
│  📍 Getting your location...    │
│                                 │
│     ○  ○  ○                     │ ← Spinner
│                                 │
│  Please wait...                 │
│                                 │
│                      [Cancel]   │
└─────────────────────────────────┘
```

### 7. Unsaved Changes Dialog

```
┌─────────────────────────────────┐
│  ⚠  Unsaved Changes             │
│                                 │
│  You have unsaved changes.      │
│  Do you want to save before     │
│  leaving?                       │
│                                 │
│  [Discard] [Cancel] [Save]      │
└─────────────────────────────────┘
```

---

## Navigation Flow

### Primary Navigation Flow

```
                    APP LAUNCH
                        │
                        ▼
                 ┌──────────────┐
                 │ Splash Screen│
                 └──────┬───────┘
                        │ (2s auto)
                        ▼
           ┌────────────────────────┐
           │   MAP VIEW SCREEN      │ ← Default
           │   (Overview Tab)       │
           └──┬──────────┬────────┬─┘
              │          │        │
    ┌─────────┘          │        └──────────┐
    │                    │                   │
    ▼                    ▼                   ▼
┌───────────┐    ┌───────────────┐   ┌──────────────┐
│ LIST VIEW │    │  NEW ENTRY    │   │   SETTINGS   │
│  SCREEN   │    │   SCREEN      │   │   SCREEN     │
└─────┬─────┘    └───────┬───────┘   └──────────────┘
      │                  │
      │                  │ [Save]
      │                  │
      ▼                  ▼
┌────────────────────────────┐
│  LANDMARK DETAIL SCREEN    │
│  (View/Edit Mode)          │
└────────────────────────────┘
```

### Detailed Navigation Paths

#### 1. Map View Navigation

```
MAP VIEW SCREEN
    │
    ├─→ Tap Marker
    │       │
    │       ▼
    │   Bottom Sheet Opens
    │       │
    │       ├─→ [Edit] → EDIT SCREEN
    │       │
    │       ├─→ [Delete] → Confirmation Dialog → MAP VIEW
    │       │
    │       └─→ [View] → DETAIL SCREEN
    │
    ├─→ Tap Search Icon → SEARCH SCREEN
    │
    ├─→ Tap Settings Icon → SETTINGS SCREEN
    │
    └─→ Bottom Nav
            ├─→ [Records] → LIST VIEW
            └─→ [New] → NEW ENTRY
```

#### 2. List View Navigation

```
LIST VIEW SCREEN
    │
    ├─→ Tap Card → DETAIL SCREEN
    │
    ├─→ Swipe Right → EDIT SCREEN
    │
    ├─→ Swipe Left → Delete Dialog → LIST VIEW
    │
    ├─→ Tap Search → SEARCH/FILTER
    │
    └─→ Bottom Nav
            ├─→ [Overview] → MAP VIEW
            └─→ [New] → NEW ENTRY
```

#### 3. New Entry Navigation

```
NEW ENTRY SCREEN
    │
    ├─→ [Save] → Validation
    │               │
    │               ├─→ Success → MAP/LIST VIEW + Snackbar
    │               │
    │               └─→ Error → Show Errors (stay on form)
    │
    ├─→ [Cancel] → Unsaved Changes Dialog?
    │                   │
    │                   ├─→ [Discard] → Previous Screen
    │                   │
    │                   ├─→ [Save] → Save + Navigate
    │                   │
    │                   └─→ [Cancel] → Stay on Form
    │
    ├─→ Tap Image → Photo Source Dialog
    │                   │
    │                   ├─→ [Camera] → Camera → Crop → Form
    │                   │
    │                   └─→ [Gallery] → Gallery → Crop → Form
    │
    ├─→ [GPS Button] → Permission Check
    │                       │
    │                       ├─→ Granted → Get Location → Fill Fields
    │                       │
    │                       └─→ Denied → Permission Dialog
    │
    └─→ Bottom Nav → Unsaved Changes Dialog → Navigate
```

#### 4. Detail Screen Navigation

```
DETAIL SCREEN
    │
    ├─→ [Edit Icon] → EDIT MODE
    │                     │
    │                     └─→ [Save] → Validation → DETAIL VIEW
    │
    ├─→ [Delete Icon] → Confirmation → Previous Screen
    │
    ├─→ [Back Arrow] → Previous Screen
    │
    ├─→ [Copy Coords] → Clipboard + Snackbar → DETAIL VIEW
    │
    ├─→ [Open Maps] → External App → Return to DETAIL VIEW
    │
    └─→ Tap Image → FULLSCREEN IMAGE VIEW
                        │
                        └─→ Pinch/Pan → Zoom
```

### Navigation Tree

```
ROOT
│
├── SPLASH SCREEN (/)
│   └─→ Auto: MAP VIEW
│
├── MAP VIEW (/map)
│   ├─→ Marker + Edit: EDIT SCREEN (/edit/:id)
│   ├─→ Marker + View: DETAIL SCREEN (/detail/:id)
│   └─→ Search: SEARCH SCREEN (/search)
│
├── LIST VIEW (/records)
│   ├─→ Card Tap: DETAIL SCREEN (/detail/:id)
│   ├─→ Swipe Edit: EDIT SCREEN (/edit/:id)
│   └─→ Search: SEARCH SCREEN (/search)
│
├── NEW ENTRY (/new)
│   ├─→ Camera: CAMERA VIEW (native)
│   ├─→ Gallery: GALLERY PICKER (native)
│   └─→ Save: MAP VIEW or LIST VIEW
│
├── DETAIL SCREEN (/detail/:id)
│   ├─→ Edit: EDIT SCREEN (/edit/:id)
│   ├─→ Image: FULLSCREEN (/image/:id)
│   └─→ Maps: EXTERNAL APP
│
├── EDIT SCREEN (/edit/:id)
│   └─→ Save: DETAIL SCREEN (/detail/:id)
│
└── SETTINGS (/settings)
    ├─→ About: ABOUT SCREEN (/about)
    ├─→ Help: HELP SCREEN (/help)
    └─→ Privacy: PRIVACY SCREEN (/privacy)
```

---

## Interaction Patterns

### 1. Gestures

**Map Screen:**
- **Pan:** Drag to move map
- **Pinch:** Zoom in/out
- **Tap:** Select marker
- **Double Tap:** Zoom in to point
- **Two-finger Tap:** Zoom out

**List Screen:**
- **Scroll:** Vertical scroll through cards
- **Swipe Left:** Reveal delete action
- **Swipe Right:** Reveal edit action
- **Pull Down:** Refresh list
- **Tap Card:** Open details

**Bottom Sheet:**
- **Drag Handle:** Expand/collapse
- **Swipe Down:** Dismiss
- **Tap Outside:** Dismiss

**Image Viewer:**
- **Pinch:** Zoom
- **Pan:** Move when zoomed
- **Double Tap:** Toggle zoom
- **Swipe Down:** Close

### 2. Feedback Mechanisms

**Visual Feedback:**
- Button press: Ripple effect
- Form validation: Red border + error text
- Success: Green checkmark + snackbar
- Loading: Circular progress indicator
- Card swipe: Background color reveal
- Selection: Highlight color change

**Haptic Feedback:**
- Button tap: Light impact
- Swipe threshold: Medium impact
- Error: Notification feedback
- Success: Success feedback
- Delete confirmation: Warning feedback

**Audio Feedback (Optional):**
- Photo capture: Shutter sound
- Success: Subtle "ding"
- Error: Error tone

### 3. Loading States

**Skeleton Screens:**
```
LIST VIEW LOADING:
┌─────────────────────────────────┐
│ ▓▓▓▓  ░░░░░░░░░░░░░░░         │
│ ▓▓▓▓  ░░░░░░░░░                │
│ ▓▓▓▓  ░░░░░                    │
└─────────────────────────────────┘
│ ▓▓▓▓  ░░░░░░░░░░░░░░░         │
│ ▓▓▓▓  ░░░░░░░░░                │
│ ▓▓▓▓  ░░░░░                    │
└─────────────────────────────────┘

MAP VIEW LOADING:
┌─────────────────────────────────┐
│         ○  ○  ○                 │
│      Loading Map...             │
└─────────────────────────────────┘
```

**Progress Indicators:**
- Image upload: Linear progress bar (0-100%)
- Form submission: Indeterminate circular spinner
- GPS detection: Spinner with timeout (30s)
- List refresh: Pull-to-refresh spinner

### 4. Error States

**Inline Errors (Forms):**
```
┌────────────────────────────┐
│ Latitude *                 │
│ ┌────────────────────────┐ │
│ │ 95.0                   │ │ ← Red border
│ └────────────────────────┘ │
│ ⚠ Must be between -90     │ ← Error message
│   and 90                   │
└────────────────────────────┘
```

**Full Screen Errors:**
```
┌─────────────────────────────────┐
│                                 │
│          ┌──────┐               │
│          │  ✗   │               │
│          └──────┘               │
│                                 │
│     Connection Failed           │
│                                 │
│  Unable to load landmarks.      │
│  Please check your internet     │
│  connection and try again.      │
│                                 │
│  ┌────────────────────────┐    │
│  │      Retry             │    │
│  └────────────────────────┘    │
│                                 │
└─────────────────────────────────┘
```

**Empty States:**
```
┌─────────────────────────────────┐
│                                 │
│          ┌──────┐               │
│          │ 📍❌ │               │
│          └──────┘               │
│                                 │
│     No landmarks found          │
│                                 │
│  Start by adding your first     │
│  landmark using the + button    │
│  below.                         │
│                                 │
└─────────────────────────────────┘
```

### 5. Animations

**Transitions:**
- Screen change: Fade (300ms)
- Bottom sheet: Slide up (250ms, ease-out)
- Dialog: Scale + fade (200ms)
- Snackbar: Slide up (150ms)

**Micro-interactions:**
- Button tap: Ripple (300ms)
- Card swipe: Spring physics
- FAB: Scale + rotate (200ms)
- Marker selection: Bounce (400ms)

**Loading:**
- Spinner: Continuous rotation
- Shimmer: 1.5s sweep cycle
- Progress bar: Smooth fill

---

## Accessibility Considerations

### 1. Touch Targets
- Minimum size: 48x48dp
- Spacing: 8dp between targets
- Primary buttons: 48dp height
- Icons: 24dp with 12dp padding

### 2. Text Contrast
- Body text: 4.5:1 ratio minimum
- Large text: 3:1 ratio minimum
- Disabled text: 2.5:1 ratio

### 3. Screen Reader Support
- All interactive elements labeled
- Image alt text descriptions
- Form field labels and hints
- Error announcements
- Success confirmations

### 4. Color Independence
- Not relying solely on color for information
- Icons + text for actions
- Patterns + colors for states
- Underlines for links

### 5. Keyboard Navigation (Tablet/Desktop)
- Tab order follows visual flow
- Focus indicators visible
- Enter/Space activates buttons
- Escape closes dialogs

---

## Responsive Considerations

### Phone (Portrait)
- Single column layouts
- Full-width cards
- Stacked buttons
- Bottom nav always visible

### Phone (Landscape)
- Map takes full width
- Bottom sheet becomes side panel
- Compact AppBar
- Form in scrollable container

### Tablet
- Multi-column layouts (List + Detail)
- Navigation rail instead of bottom nav
- Floating dialogs (not full screen)
- Master-detail pattern

### Desktop (Web)
- Max content width: 1200dp
- Centered layouts
- Hover states
- Keyboard shortcuts
- Mouse context menus

---

## Technical Notes

### Map Implementation
- **Library:** Google Maps Flutter / OpenStreetMap
- **Markers:** Custom PNG assets (32x48dp @3x)
- **Clustering:** Enabled for 10+ markers in viewport
- **Offline:** Cache tiles for Bangladesh region
- **Performance:** Limit markers to 500, use clustering

### Image Handling
- **Max size:** 5MB per image
- **Compression:** 85% quality JPEG
- **Dimensions:** Max 1920x1080px
- **Thumbnail:** 200x200px cached
- **Storage:** Local + optional cloud backup

### Form Validation
- **Real-time:** On field blur
- **Debounce:** 500ms for async checks
- **Required fields:** Title, Latitude, Longitude
- **Coordinate precision:** 6 decimal places

### Performance Targets
- **Time to Interactive:** < 3s
- **List scroll:** 60fps
- **Map pan:** 60fps
- **Image load:** < 1s (cached)
- **Form submit:** < 2s

---

## Version History

**v1.0.0** - Initial wireframe design
- Core 3-screen layout
- Bottom navigation
- Map with markers
- List with swipe actions
- Form with GPS detection
- Detail/edit screens

---

## Future Enhancements

**Phase 2:**
- Search and filter functionality
- Categories with color coding
- Export to KML/GPX
- Share landmarks
- Offline mode
- Multi-language support

**Phase 3:**
- Social features (comments, ratings)
- Photo galleries per landmark
- Audio notes
- Route planning
- AR view
- Dark mode

---

## Design Assets Needed

### Icons (24dp, Material Design)
- Map pin (filled, outlined)
- List/grid toggle
- Plus/add
- Edit (pencil)
- Delete (trash)
- Camera
- Gallery
- GPS/location
- Search
- Settings
- Save/check
- Cancel/close
- Share
- Copy
- External link

### Images
- App logo (512x512px)
- Splash screen background
- Empty state illustrations
- Error state illustrations
- Onboarding graphics (optional)

### Fonts
- Primary: Roboto (default Material)
- Alternative: Open Sans, Inter

---

## Summary

This wireframe document provides comprehensive layouts for all screens in the Landmark Management app. Key features include:

- **3 main tabs:** Map overview, record list, new entry form
- **Interactive map** with custom markers and bottom sheets
- **Swipeable cards** for quick edit/delete actions
- **Smart form** with GPS auto-detection and image picker
- **Consistent navigation** with bottom nav and clear hierarchy
- **Robust error handling** with dialogs and snackbars
- **Responsive design** considerations for multiple devices

The design prioritizes:
- **Ease of use:** Minimal taps to complete tasks
- **Visual clarity:** Clean layouts with clear hierarchy
- **Feedback:** Immediate response to user actions
- **Accessibility:** Large touch targets, good contrast, screen reader support
- **Performance:** Smooth animations and quick load times

All screens follow Material Design principles while maintaining a unique identity for the landmark management domain.
