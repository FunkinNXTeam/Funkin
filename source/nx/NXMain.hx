package nx;

import nx.controls.NXController;
#if switch
import lime.media.AudioManager;
#end

/**
 * States of the applet
 */
enum AppletStateMode
{
  /**
   * The applet/program is in focus
   */
  APP_IN_FOCUS;

  /**
   * The applet/program is out of focus
   */
  APP_OUT_OF_FOCUS;

  /**
   * The applet/program is suspended (In HOME menu or the console is sleeping)
   */
  APP_SUSPENDED;

  /**
   * Unknown state
   */
  APP_UNKNOWN;
}

/**
 * Main class for Nintendo Switch functionality
 *
 * Ported from Switch-Funkin
 */
class NXMain
{
  /**
   * Controller manager for Nintendo Switch controllers
   */
  public static var nxController:NXController = null;

  /**
   * Previous app state for detecting state changes
   */
  private static var _previousAppState:AppletStateMode = APP_UNKNOWN;

  /**
   * Whether audio is currently suspended by us
   */
  private static var _audioSuspended:Bool = false;

  /**
   * Whether the app has been in focus at least once (game fully started)
   */
  private static var _hasBeenInFocus:Bool = false;

  /**
   * Initialize Nintendo Switch systems
   */
  public static function init()
  {
    #if switch
    nxController = new NXController();
    _previousAppState = appState;
    _hasBeenInFocus = (_previousAppState == APP_IN_FOCUS);
    #end
  }

  /**
   * Update Nintendo Switch systems - called every frame
   */
  public static function update()
  {
    #if switch
    if (nxController != null)
    {
      nxController.update();
    }

    handleAudioState();
    #end
  }

  /**
   * Handle audio context suspension when app loses focus or is suspended.
   * This fixes the OpenAL bug where audio stops working after the app goes to background.
   */
  private static function handleAudioState():Void
  {
    #if switch
    var currentState = appState;

    if (!_hasBeenInFocus && currentState == APP_IN_FOCUS)
    {
      _hasBeenInFocus = true;
      _previousAppState = currentState;
      return;
    }

    if (!_hasBeenInFocus)
    {
      _previousAppState = currentState;
      return;
    }

    if (currentState == _previousAppState)
    {
      return;
    }

    if (AudioManager.context == null)
    {
      _previousAppState = currentState;
      return;
    }

    if (currentState == APP_OUT_OF_FOCUS || currentState == APP_SUSPENDED)
    {
      if (_previousAppState == APP_IN_FOCUS && !_audioSuspended)
      {
        AudioManager.suspend();
        _audioSuspended = true;
      }
    }
    else if (currentState == APP_IN_FOCUS)
    {
      if (_audioSuspended)
      {
        AudioManager.resume();
        _audioSuspended = false;
      }
    }

    _previousAppState = currentState;
    #end
  }

  /**
   * Clean up Nintendo Switch systems
   */
  public static function destroy()
  {
    #if switch
    if (nxController != null)
    {
      nxController.destroy();
    }
    #end
  }

  /**
   * Checks if the console is docked (TV mode)
   */
  public static var IS_DOCKED(get, never):Bool;

  private static function get_IS_DOCKED():Bool
  {
    #if switch
    return Applet.appletGetOperationMode() == AppletOperationMode.AppletOperationMode_Console;
    #else
    return false;
    #end
  }

  /**
   * The current applet state
   */
  public static var appState(get, never):AppletStateMode;

  private static function get_appState():AppletStateMode
  {
    #if switch
    return switch (Applet.appletGetFocusState())
    {
      case AppletFocusState.AppletFocusState_InFocus: AppletStateMode.APP_IN_FOCUS;
      case AppletFocusState.AppletFocusState_OutOfFocus: AppletStateMode.APP_OUT_OF_FOCUS;
      case AppletFocusState.AppletFocusState_Background: AppletStateMode.APP_SUSPENDED;
      default: AppletStateMode.APP_UNKNOWN;
    }
    #else
    return AppletStateMode.APP_UNKNOWN;
    #end
  }

  /**
   * Checks if the application is running in Applet mode (limited memory)
   * @return Bool
   */
  public static function isRunningAsApplet():Bool
  {
    #if switch
    return Applet.appletGetAppletType() != AppletType.AppletType_Application
      && Applet.appletGetAppletType() != AppletType.AppletType_SystemApplication;
    #else
    return false;
    #end
  }
}
