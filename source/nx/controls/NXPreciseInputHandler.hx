package nx.controls;

#if switch
import haxe.Int64;
import funkin.input.PreciseInputManager;
import funkin.play.notes.NoteDirection;
import nx.NXMain;
import nx.controls.NXControlButton;

class NXPreciseInputHandler
{
  public var onButtonPressed:Null<(NoteDirection, Int64, Int) -> Void> = null;
  public var onButtonReleased:Null<(NoteDirection, Int64, Int) -> Void> = null;

  private var _prevDpadUp:Bool = false;
  private var _prevDpadDown:Bool = false;
  private var _prevDpadLeft:Bool = false;
  private var _prevDpadRight:Bool = false;
  private var _prevY:Bool = false;
  private var _prevA:Bool = false;
  private var _prevX:Bool = false;
  private var _prevB:Bool = false;

  public function new() {}

  /**
   * Update the input handler - should be called every frame.
   * Checks for button state changes and dispatches events.
   */
  public function update():Void
  {
    var controller = NXMain.nxController;
    if (controller == null) return;

    var timestamp = getCurrentTimestamp();

    checkButton(controller, UP, NoteDirection.UP, _prevDpadUp, timestamp, 0);
    checkButton(controller, DOWN, NoteDirection.DOWN, _prevDpadDown, timestamp, 1);
    checkButton(controller, LEFT, NoteDirection.LEFT, _prevDpadLeft, timestamp, 2);
    checkButton(controller, RIGHT, NoteDirection.RIGHT, _prevDpadRight, timestamp, 3);
    checkButton(controller, X, NoteDirection.UP, _prevY, timestamp, 4);
    checkButton(controller, B, NoteDirection.DOWN, _prevA, timestamp, 5);
    checkButton(controller, Y, NoteDirection.LEFT, _prevX, timestamp, 6);
    checkButton(controller, A, NoteDirection.RIGHT, _prevB, timestamp, 7);

    _prevDpadUp = controller.isPressed(UP);
    _prevDpadDown = controller.isPressed(DOWN);
    _prevDpadLeft = controller.isPressed(LEFT);
    _prevDpadRight = controller.isPressed(RIGHT);
    _prevY = controller.isPressed(X);
    _prevA = controller.isPressed(B);
    _prevX = controller.isPressed(Y);
    _prevB = controller.isPressed(A);
  }

  private function checkButton(controller:NXController, button:NXControlButton, direction:NoteDirection, prevState:Bool, timestamp:Int64, buttonCode:Int):Void
  {
    var currentState = controller.isPressed(button);

    if (currentState && !prevState)
    {
      if (onButtonPressed != null)
      {
        onButtonPressed(direction, timestamp, buttonCode);
      }
    }
    else if (!currentState && prevState)
    {
      if (onButtonReleased != null)
      {
        onButtonReleased(direction, timestamp, buttonCode);
      }
    }
  }

  private static function getCurrentTimestamp():Int64
  {
    return PreciseInputManager.getCurrentTimestamp();
  }

  public function destroy():Void
  {
    onButtonPressed = null;
    onButtonReleased = null;
  }
}
#end
