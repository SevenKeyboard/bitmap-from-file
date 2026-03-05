#Requires AutoHotkey v1.1.21+
#Include %A_ScriptDir%
#Include .\vendor\Gdip_All.ahk ;  Tested with https://github.com/mmikeww/AHKv2-Gdip/blob/cab5ae291023c790ce4081630b190b5b88409f48/Gdip_All.ahk
;==============================================================
; BitmapFromFile — GDI+ bitmap loader with automatic disposal (__Delete + OnExit fallback)
;
; GitHub: https://github.com/SevenKeyboard/bitmap-from-file
; Author: SevenKeyboard Ltd. (2026)
; License: The Unlicense
;==============================================================
class VersionManager_BitmapFromFile
{
    static _ := VersionManager_BitmapFromFile._init()
    _init()    {
        global
        BITMAPFROMFILE_VERSION := "1.0.2"
    }
}
class BitmapFromFile
{
    __new(fileName)    {
        this._pBitmap := 0
        this._pBitmap := Gdip_CreateBitmapFromFile(fileName)
        if (this._pBitmap)
            this.base.OnExitDisposer.register(this._pBitmap)
    }
    __delete()    {
        if (this._pBitmap)    {
            this.base.OnExitDisposer.unregister(this._pBitmap)
            dllCall("Gdiplus.dll\GdipDisposeImage", "Ptr",this._pBitmap, "UInt")
            this._pBitmap := 0
        }
    }
    PBitmap    {
        get  {
            return this._pBitmap
        }
    }
    class OnExitDisposer
    {
        static _handles := object()
        register(pBitmap)    { ;  static
            static init := false
            if (!init)    {
                init := true
                onExit(objBindMethod(this, "_exiting"))
            }
            if (pBitmap := format("{:d}", pBitmap))
                this._handles[pBitmap] := true
        }
        unregister(pBitmap)    { ;  static
            if (this._handles.hasKey(pBitmap := format("{:d}", pBitmap)))
                this._handles.delete(pBitmap)
        }
        _exiting(exitReason, exitCode)    { ;  static
            handles := this._handles.clone()
            this._handles := object()
            for pBitmap in handles
                dllCall("Gdiplus.dll\GdipDisposeImage", "Ptr",pBitmap, "UInt")
        }
    }
}