# Qt Bug Report: Windows On-Screen Keyboard becomes "sticky" after TextInput loses focus

## Summary

On Windows in tablet mode, after a `TextInput` or `TextField` gains focus and the On-Screen Keyboard (OSK) appears, the OSK continues to appear on subsequent touch interactions anywhere in the application... even after the input has lost focus, been hidden, or been destroyed. The OSK association persists incorrectly at the Windows platform level.

## Environment

- **Qt Version**: 6.8.x (tested on 6.8.6)
- **Platform**: Windows 11 in Tablet Mode
- **Components affected**: `TextInput`, `TextField`, Windows QPA plugin

## Steps to Reproduce

A minimal reproducer is available at: https://github.com/paulmasri/QtBugTextInputOSK

1. Run the application on a Windows tablet (or Windows PC in tablet mode)
2. Select "MouseArea (has bug)" mode
3. Tap "Show Input Panel"
4. Tap on a text input field — OSK appears (correct)
5. Close the OSK manually (tap the X on OSK)
6. Tap "Clear Focus" button — input loses focus, diagnostics confirm no input has `activeFocus`
7. Tap "Close" button — panel closes **and OSK appears** (BUG)
8. Close OSK, tap anywhere on main rectangle — OSK appears again (BUG)

## Expected Behavior

- OSK should only appear when a text input has focus
- After focus moves away from a text input, OSK should not reappear on unrelated touch events
- After a text input is destroyed, OSK should not reappear on unrelated touch events
- `Qt.inputMethod.hide()` should permanently dismiss the OSK until a new input gains focus

## Actual Behavior

The Windows platform plugin appears to cache the input method association. Once OSK has appeared for a TextInput:

1. **Focus transfer doesn't clear the association**: Even after `forceActiveFocus()` moves focus to a non-input item, subsequent touches trigger OSK
2. **Hiding doesn't clear the association**: `Qt.inputMethod.hide()` dismisses the OSK visually but doesn't clear the underlying Windows input context
3. **Destruction doesn't clear the association**: Even after the TextInput is destroyed (Loader.sourceComponent = null), the sticky behavior persists

## Root Cause Analysis

The issue is in how Qt's Windows QPA plugin communicates with the Windows input method/accessibility layer:

### What doesn't work:
- `Qt.inputMethod.hide()` — hides OSK but doesn't clear Windows' cached input context
- `Qt.inputMethod.commit()` — commits pending text but doesn't clear the input context
- `forceActiveFocus()` on a non-input item — QML focus changes but Windows isn't notified
- `forceActiveFocus()` on a `readOnly` TextInput — even another TextInput doesn't clear the association
- Destroying the TextInput — Windows still thinks the input context is valid

### What does work:
- Clicking a `Button` component (from QtQuick.Controls) before closing — Button takes focus, which triggers a proper platform-level `focusOut` event on the TextInput, causing Windows to release the input context

### Conclusion:
The Windows platform plugin does not properly notify Windows to release the text input context when:
1. A TextInput loses `activeFocus` through QML focus transfer
2. A TextInput becomes invisible
3. A TextInput is destroyed
4. `Qt.inputMethod.hide()` is called

Only a proper platform-level focus transfer (as happens with Button click) correctly signals Windows to release the input association.

## Workaround

Use `Button` components (from QtQuick.Controls) instead of `MouseArea` for interactive elements in applications that use text inputs. Button's built-in focus handling triggers the correct platform-level events.

## Test Cases in Reproducer

The reproducer app includes:

1. **Mode selector**: Switch between "MouseArea (has bug)" and "Button (works)" close button implementations
2. **Clear Focus button**: Moves focus to a non-input Item
3. **Commit button**: Calls `Qt.inputMethod.commit()`
4. **ReadOnly TextInput**: Tests if focus transfer to another TextInput clears the association
5. **Focus diagnostics**: Shows `activeFocus` state for all inputs

### Test Results:

| Scenario | Close Method | Action Before Close | Result |
|----------|--------------|---------------------|--------|
| A | MouseArea | None | OSK appears on close, sticky thereafter |
| B | MouseArea | Clear Focus (to Item) | OSK still appears on close |
| C | MouseArea | Tap ReadOnly TextInput | OSK still appears on close |
| D | MouseArea | Commit | OSK still appears on close |
| E | Button | None | OSK does not appear, no sticky behavior |
| F | Button | Any of the above | OSK does not appear, no sticky behavior |

Tests B, C, and D are particularly important: they prove the bug is **not** about QML focus state. Even with focus explicitly transferred away from inputs (including to another TextInput), the Windows input context remains cached.

## Related Issues

- QTBUG-122892: Password echoMode hides OSK on Windows tablet mode
- QTBUG-100223: Touchscreen discrepancy between QML TextInput and QLineEdit with Windows virtual keyboard

## Suggested Fix

The Windows QPA plugin should:

1. Notify Windows to release the input context when `QInputMethod::hide()` is called
2. Notify Windows to release the input context when the focused input item loses `activeFocus`
3. Notify Windows to release the input context when the focused input item is destroyed
4. Ensure that touch events on non-input items do not reactivate a previously-used input context
