# Forum rc.6.7 test branch

This is a test build from `fix/forum-rc6-7-reports`. It is not a release and must not be merged automatically.

- N1: macOS field scrolling now invalidates the full field, including native scrollbar strips. The regression tour now also exercises the editor's hidden-border, dual-scrollbar configuration. Confirmation on the reporter's macOS version is still needed.
- N2–N3: Preferences > Script Editor > Colorization Scheme > Follow System Appearance selects paired light/dark defaults. Existing users must opt in: older builds saved their default white as an explicit RGB value. Existing explicit backgrounds stay explicit. Follow mode is saved as empty, which older builds read as their own default; the mode sentinel is never written to disk. `cScriptEditor,colorization,schemedark` is now read in dark appearance. Open editors refresh on the IDE appearance message.
- N4: Project Browser script-count badges use white on a dark blue background, with a shared dark red error color in both themes and selection states.
- N5: Modern Tools palette drawn icons use stronger light/dark foregrounds. Its menu already offers Drawn Icons off for original pictures and Large Icons on for enlargement.
- N6: The report does not identify a window. No claim of a fix without that information. For the Tools palette, try Large Icons, names, window resizing, and scrolling at 1024×768.
- N7: Modern Tools uses an outlined SVG caption reading "Label", with no input box or caret. It scales with Large Icons and follows the icon contrast colors. Drawn Icons off still selects the original pictures.
- N8: The web player draws a transport placeholder when its native layer is hidden for editing. Provider watch-page URLs (Vimeo/YouTube) are not media files; use a direct supported media URL or the provider's permitted embed page in a browser widget. Provider-specific playback has not been added.

Test in light and dark appearance, switching while an editor is open; repeat with a custom background. On Linux select and deselect Project Browser rows, including script-error rows. On macOS scroll a long script both ways with both scrollbars present, then compare with hiding and showing the editor. In the web IDE select a player in edit mode and switch back to browse mode with a direct MP4/WebM URL.
