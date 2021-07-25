using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Lang;
using Toybox.System;
using Toybox.Communications;

class DanceDanceGarminView extends WatchUi.WatchFace {
    private var _animationDelegate;


    function initialize() {
        WatchFace.initialize();
        _animationDelegate = new DanceDanceAnimationController();
    }

    // Load your resources here
    function onLayout(dc) {
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
        _animationDelegate.handleOnShow(self);
        _animationDelegate.play();
        //Module 'Toybox.Communications' not available to 'Watch Face'
        //executeWebCall();
    }
    
    // set up the response callback function
   function onReceive(responseCode, data) {
       if (responseCode == 200) {
           System.println("Request Successful" + "Data Received : " + data);                   // print success
       }
       else {
           System.println("Response: " + responseCode);            // print response code
       }

   }
    
    private function executeWebCall(){
    	 var url = "https://httpbin.org/get";                         // set the url

       var params = {                                              // set the parameters
              "api_call" => "random_params"
       };

       var options = {                                             // set the options
           :method => Communications.HTTP_REQUEST_METHOD_GET,      // set HTTP method
           :headers => {                                           // set headers
                   "Content-Type" => Communications.REQUEST_CONTENT_TYPE_JSON},
                                                                   // set response type
           :responseType => Communications.REQUEST_CONTENT_TYPE_JSON
       };

       var responseCallback = method(:onReceive);                  // set responseCallback to
                                                                   // onReceive() method
       // Make the Communications.makeWebRequest() call
       Communications.makeWebRequest(url, params, options, method(:onReceive));
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
        _animationDelegate.handleOnHide(self);
    }

    // Build up the time string
    private function getTimeString() {
        var clockTime = System.getClockTime();
        var info = System.getDeviceSettings();

        var hour = clockTime.hour;

        if( !info.is24Hour ) {
            hour = clockTime.hour % 12;
            if (hour == 0) {
                hour = 12;
            }
        }

        return Lang.format("$1$:$2$", [hour, clockTime.min.format("%02d")]);
    }


    // Function to render the time on the time layer
    private function updateTimeLayer() {
        var dc = _animationDelegate.getTextLayer().getDc();
        var width = dc.getWidth();
        var height = dc.getHeight();

        // Clear the layer contents
        var timeString = getTimeString();
        dc.setColor(Graphics.COLOR_TRANSPARENT, Graphics.COLOR_TRANSPARENT);
        dc.clear();
        // Draw the time in the middle
        dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(width / 2, height / 2, Graphics.FONT_NUMBER_MEDIUM, timeString,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }


    // Update the view
    function onUpdate(dc) {
        // Clear the screen buffer
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_WHITE);
        dc.clear();
        // Update the contents of the time layer
        updateTimeLayer();
        return;
    }


    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() {
         _animationDelegate.play();
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() {
         _animationDelegate.stop();
    }

}
