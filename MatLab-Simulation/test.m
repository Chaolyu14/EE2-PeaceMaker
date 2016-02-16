

function test(rec)
  f= figure ;
  uicontrol(f,'style','pushbutton','position',[10 10 200 40],'String','start Record','CallBack',@button1Callback) ;
  function button1Callback(~,~)
      disp('Recording... start talking');
      rec.record();
  end
  uicontrol(f,'style','pushbutton','position',[220 10 200 40],'String','stop record','CallBack',@button2Callback) ;
  function button2Callback(~,~)
      disp('Recording finished');
      rec.stop();
  end
 uicontrol(f,'style','pushbutton','position',[430 10 200 40],'String','play record','CallBack',@button3Callback) ;
  function button3Callback(~,~)
      disp('playing record');
      rec.play();
  end
end
