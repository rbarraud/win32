;;;Copyright (c) 2013 Wilfredo Velázquez-Rodríguez
;;;
;;;This software is provided 'as-is', without any express or implied
;;;warranty. In no event will the authors be held liable for any damages
;;;arising from the use of this software.
;;;
;;;Permission is granted to anyone to use this software for any purpose,
;;;including commercial applications, and to alter it and redistribute
;;;it freely, subject to the following restrictions:
;;;
;;;1. The origin of this software must not be misrepresented; you must not
;;;   claim that you wrote the original software. If you use this software
;;;   in a product, an acknowledgment in the product documentation would
;;;   be appreciated but is not required.
;;;
;;;2. Altered source versions must be plainly marked as such, and must not
;;;   be misrepresented as being the original software.
;;;
;;;3. This notice may not be removed or altered from any source distribution.

(in-package #:win32)

(define-foreign-library kernel32
  (:win32 "Kernel32"))

(define-foreign-library user32
  (:win32 "User32"))

(define-foreign-library gdi32
  (:win32 "Gdi32"))

(define-foreign-library opengl32
  (:win32 "Opengl32"))

(define-foreign-library advapi32
  (:win32 "Advapi32.dll"))

(use-foreign-library user32)
(use-foreign-library kernel32)
(use-foreign-library gdi32)
(use-foreign-library opengl32)
(use-foreign-library advapi32)

(defconstant +win32-string-encoding+
  #+little-endian :utf-16le
  #+big-endian :utf-16be
  "Not a win32 'constant' per-se, but useful to expose for usage with FOREIGN-STRING-TO-LISP and friends.")

(defctype char :int8)
(defctype uchar :uchar)
(defctype wchar :int16)

(defctype int :int)
(defctype int-ptr #+x86 :int32 #+x86-64 :int64)
(defctype int8 :int8)
(defctype int16 :int16)
(defctype int32 :int32)
(defctype int64 :int64)

(defctype uint :uint32)
(defctype uint-ptr #+x86 :uint32 #+x86-64 :uint64)
(defctype uint8 :uint8)
(defctype uint16 :uint16)
(defctype uint32 :uint32)
(defctype uint64 :uint64)

(defctype long :long)
(defctype longlong :int64)
(defctype long-ptr #+x86 :int32 #+x86-64 :int64)
(defctype long32 :int32)
(defctype long64 :int64)

(defctype ulong :uint32)
(defctype ulonglong :uint64)
(defctype ulong-ptr #+x86 :uint32 #+x86-64 :uint64)
(defctype ulong32 :uint32)
(defctype ulong64 :uint64)

(defctype short :short)
(defctype ushort :ushort)

(defctype byte :uint8)
(defctype word :uint16)
(defctype dword :uint32)
(defctype dwordlong :uint64)
(defctype dword-ptr ulong-ptr)
(defctype dword32 :uint32)
(defctype dword64 :uint64)
(defctype qword :uint64)

(defctype bool :int)
(defctype boolean byte)

(defctype tbyte wchar)
(defctype tchar wchar)

(defctype float :float)

(defctype size-t #+x86 :uint32 #+x86-64 :uint64)
(defctype ssize-t #+x86 :int32 #+x86-64 :int64)

(defctype lpcstr (:string :encoding :ascii))
(defctype lpcwstr (:string :encoding #.+win32-string-encoding+))
(defctype lpstr (:string :encoding :ascii))
(defctype lpwstr (:string :encoding #.+win32-string-encoding+))
(defctype pcstr (:string :encoding :ascii))
(defctype pcwstr (:string :encoding #.+win32-string-encoding+))
(defctype pstr (:string :encoding :ascii))
(defctype pwstr (:string :encoding #.+win32-string-encoding+))

(defctype handle :pointer)

(defctype atom :uint16)
(defctype half-ptr #+x86 :int #+x86-64 :short)
(defctype uhalf-ptr #+x86 :uint #+x86-64 :ushort)
(defctype colorref :uint32)
(defctype haccel handle)
(defctype hbitmap handle)
(defctype hbrush handle)
(defctype hcolorspace handle)
(defctype hconv handle)
(defctype hconvlist handle)
(defctype hcursor handle)
(defctype hdc handle)
(defctype hddedata handle)
(defctype hdesk handle)
(defctype hdrop handle)
(defctype hdwp handle)
(defctype henhmetafile handle)
(defctype hfile :int)
(defctype hfont handle)
(defctype hgdiobj handle)
(defctype hglobal handle)
(defctype hhook handle)
(defctype hicon handle)
(defctype hinstance handle)
(defctype hkey handle)
(defctype hkl handle)
(defctype hlocal handle)
(defctype hmenu handle)
(defctype hmetafile handle)
(defctype hmodule hinstance)
(defctype hmonitor handle)
(defctype hpalette handle)
(defctype hpen handle)
(defctype hresult long)
(defctype hrgn handle)
(defctype hrsrc handle)
(defctype hsz handle)
(defctype hwinsta handle)
(defctype hwnd handle)
(defctype langid word)
(defctype lcid dword)
(defctype lgrpid dword)
(defctype lparam long-ptr)
(defctype lpctstr lpcwstr)
(defctype lptstr lpwstr)
(defctype lresult long-ptr)
(defctype pctstr pcwstr)
(defctype ptstr pwstr)
(defctype sc-handle handle)
(defctype sc-lock :pointer)
(defctype service-status-handle handle)
(defctype usn longlong)
(defctype wparam uint-ptr)

(eval-when (:compile-toplevel :load-toplevel :execute)
  (defun %to-int32 (value)
    "Makes it easier to declare certain high values which in C are int32, in hex.
  For example, the constant +cw-usedefault+ must be used in int32 contexts, but is declared
  to be 0x80000000, which when interpreted by lisp is a high positive number  and does not
  have the same binary memory representation as the C interpreted negative value."
    (cond
      ((> value #xFFFFFFFF)
       (error "The value ~A cannot be represented as an int32 as its value does not fit into 32-bits." value))
      ((> value #x7FFFFFFF)
       (1- (-  value #xFFFFFFFF)))
      ((>= value 0)
       value)
      (t
       (error "The value ~A cannot be converted at this time, as negatives are not supported." value)))))

;;CreateFile Creation Disposition
(defconstant +create-new+        1)
(defconstant +create-always+     2)
(defconstant +open-existing+     3)
(defconstant +open-always+       4)
(defconstant +truncate-existing+ 5)

;;Pixel types
(defconstant +pfd-type-rgba+        0)
(defconstant +pfd-type-colorindex+  1)

;;Layer types
(defconstant +pfd-main-plane+       0)
(defconstant +pfd-overlay-plane+    1)
(defconstant +pfd-underlay-plane+   -1)

;;Flags
(defconstant +pfd-doublebuffer+            #x00000001)
(defconstant +pfd-stereo+                  #x00000002)
(defconstant +pfd-draw-to-window+          #x00000004)
(defconstant +pfd-draw-to-bitmap+          #x00000008)
(defconstant +pfd-support-gdi+             #x00000010)
(defconstant +pfd-support-opengl+          #x00000020)
(defconstant +pfd-generic-format+          #x00000040)
(defconstant +pfd-need-palette+            #x00000080)
(defconstant +pfd-need-system-palette+     #x00000100)
(defconstant +pfd-swap-exchange+           #x00000200)
(defconstant +pfd-swap-copy+               #x00000400)
(defconstant +pfd-swap-layer-buffers+      #x00000800)
(defconstant +pfd-generic-accelerated+     #x00001000)
(defconstant +pfd-support-directdraw+      #x00002000)
(defconstant +pfd-direct3d-accelerated+    #x00004000)
(defconstant +pfd-support-composition+     #x00008000)
(defconstant +pfd-depth-dontcare+          #x20000000)
(defconstant +pfd-doublebuffer-dontcare+   #x40000000)
(defconstant +pfd-stereo-dontcare+         #x80000000)

;;Window styles
(defconstant +ws-overlapped+     #x00000000)
(defconstant +ws-popup+          #x80000000)
(defconstant +ws-child+          #x40000000)
(defconstant +ws-visible+        #x10000000)
(defconstant +ws-caption+        #x00C00000)
(defconstant +ws-border+         #x00800000)
(defconstant +ws-tabstop+        #x00010000)
(defconstant +ws-maximizebox+    #x00010000)
(defconstant +ws-minimizebox+    #x00020000)
(defconstant +ws-thickframe+     #x00040000)
(defconstant +ws-sysmenu+        #x00080000)

(defconstant +ws-overlappedwindow+ (logior +ws-overlapped+ +ws-caption+ +ws-sysmenu+ +ws-thickframe+ +ws-minimizebox+ +ws-maximizebox+))

;;Window ex styles
(defconstant +ws-ex-left+                 #x00000000)
(defconstant +ws-ex-ltrreading+           #x00000000)
(defconstant +ws-ex-rightscrollbar+       #x00000000)
(defconstant +ws-ex-dlgmodalframe+        #x00000001)
(defconstant +ws-ex-noparentnotify+       #x00000004)
(defconstant +ws-ex-topmost+              #x00000008)
(defconstant +ws-ex-acceptfiles+          #x00000010)
(defconstant +ws-ex-transparent+          #x00000020)
(defconstant +ws-ex-mdichild+             #x00000040)
(defconstant +ws-ex-toolwindow+           #x00000080)
(defconstant +ws-ex-windowedge+           #x00000100)
(defconstant +ws-ex-clientedge+           #x00000200)
(defconstant +ws-ex-contexthelp+          #x00000400)
(defconstant +ws-ex-right+                #x00001000)
(defconstant +ws-ex-rtlreading+           #x00002000)
(defconstant +ws-ex-leftscrollbar+        #x00004000)
(defconstant +ws-ex-controlparent+        #x00010000)
(defconstant +ws-ex-staticedge+           #x00020000)
(defconstant +ws-ex-appwindow+            #x00040000)
(defconstant +ws-ex-noinheritlayout+      #x00100000)
(defconstant +ws-ex-noredirectionbitmap+  #x00200000)
(defconstant +ws-ex-layoutrtl+            #x00400000)
(defconstant +ws-ex-composited+           #x02000000)
(defconstant +ws-ex-noactivate+           #x08000000)

(defconstant +ws-ex-overlapped-window+    (logior
                                           +ws-ex-windowedge+
                                           +ws-ex-clientedge+))
(defconstant +ws-ex-palettewindow+        (logior
                                           +ws-ex-windowedge+
                                           +ws-ex-toolwindow+
                                           +ws-ex-topmost+))

;;Edit control types
(defconstant +es-left+ #x0000)
(defconstant +es-center+ #x0001)
(defconstant +es-right+ #x0002)

(defconstant +wm-null+                     #x0000)
(defconstant +wm-create+                   #x0001)
(defconstant +wm-destroy+                  #x0002)
(defconstant +wm-move+                     #x0003)
(defconstant +wm-size+                     #x0005)
(defconstant +wm-activate+                 #x0006)
(defconstant +wm-setfocus+                 #x0007)
(defconstant +wm-killfocus+                #x0008)
(defconstant +wm-enable+                   #x000A)
(defconstant +wm-setredraw+                #x000B)
(defconstant +wm-settext+                  #x000C)
(defconstant +wm-gettext+                  #x000D)
(defconstant +wm-gettextlength+            #x000E)
(defconstant +wm-paint+                    #x000F)
(defconstant +wm-close+                    #x0010)
(defconstant +wm-queryendsession+          #x0011)
(defconstant +wm-quit+                     #x0012)
(defconstant +wm-queryopen+                #x0013)
(defconstant +wm-erasebkgnd+               #x0014)
(defconstant +wm-syscolorchange+           #x0015)
(defconstant +wm-endsession+               #x0016)
(defconstant +wm-systemerror+              #x0017)
(defconstant +wm-showwindow+               #x0018)
(defconstant +wm-ctlcolor+                 #x0019)
(defconstant +wm-wininichange+             #x001A)
(defconstant +wm-settingchange+            #x001A)
(defconstant +wm-devmodechange+            #x001B)
(defconstant +wm-activateapp+              #x001C)
(defconstant +wm-fontchange+               #x001D)
(defconstant +wm-timechange+               #x001E)
(defconstant +wm-cancelmode+               #x001F)
(defconstant +wm-setcursor+                #x0020)
(defconstant +wm-mouseactivate+            #x0021)
(defconstant +wm-childactivate+            #x0022)
(defconstant +wm-queuesync+                #x0023)
(defconstant +wm-getminmaxinfo+            #x0024)
(defconstant +wm-painticon+                #x0026)
(defconstant +wm-iconerasebkgnd+           #x0027)
(defconstant +wm-nextdlgctl+               #x0028)
(defconstant +wm-spoolerstatus+            #x002A)
(defconstant +wm-drawitem+                 #x002B)
(defconstant +wm-measureitem+              #x002C)
(defconstant +wm-deleteitem+               #x002D)
(defconstant +wm-vkeytoitem+               #x002E)
(defconstant +wm-chartoitem+               #x002F)
(defconstant +wm-setfont+                  #x0030)
(defconstant +wm-getfont+                  #x0031)
(defconstant +wm-sethotkey+                #x0032)
(defconstant +wm-gethotkey+                #x0033)
(defconstant +wm-querydragicon+            #x0037)
(defconstant +wm-compareitem+              #x0039)
(defconstant +wm-compacting+               #x0041)
(defconstant +wm-windowposchanging+        #x0046)
(defconstant +wm-windowposchanged+         #x0047)
(defconstant +wm-power+                    #x0048)
(defconstant +wm-copydata+                 #x004A)
(defconstant +wm-canceljournal+            #x004B)
(defconstant +wm-notify+                   #x004E)
(defconstant +wm-inputlangchangerequest+   #x0050)
(defconstant +wm-inputlangchange+          #x0051)
(defconstant +wm-tcard+                    #x0052)
(defconstant +wm-help+                     #x0053)
(defconstant +wm-userchanged+              #x0054)
(defconstant +wm-notifyformat+             #x0055)
(defconstant +wm-contextmenu+              #x007B)
(defconstant +wm-stylechanging+            #x007C)
(defconstant +wm-stylechanged+             #x007D)
(defconstant +wm-displaychange+            #x007E)
(defconstant +wm-geticon+                  #x007F)
(defconstant +wm-seticon+                  #x0080)
(defconstant +wm-nccreate+                 #x0081)
(defconstant +wm-ncdestroy+                #x0082)
(defconstant +wm-nccalcsize+               #x0083)
(defconstant +wm-nchittest+                #x0084)
(defconstant +wm-ncpaint+                  #x0085)
(defconstant +wm-ncactivate+               #x0086)
(defconstant +wm-getdlgcode+               #x0087)
(defconstant +wm-syncpaint+                #x0088)
(defconstant +wm-ncmousemove+              #x00A0)
(defconstant +wm-nclbuttondown+            #x00A1)
(defconstant +wm-nclbuttonup+              #x00A2)
(defconstant +wm-nclbuttondblclk+          #x00A3)
(defconstant +wm-ncrbuttondown+            #x00A4)
(defconstant +wm-ncrbuttonup+              #x00A5)
(defconstant +wm-ncrbuttondblclk+          #x00A6)
(defconstant +wm-ncmbuttondown+            #x00A7)
(defconstant +wm-ncmbuttonup+              #x00A8)
(defconstant +wm-ncmbuttondblclk+          #x00A9)
(defconstant +wm-keyfirst+                 #x0100)
(defconstant +wm-keydown+                  #x0100)
(defconstant +wm-keyup+                    #x0101)
(defconstant +wm-char+                     #x0102)
(defconstant +wm-deadchar+                 #x0103)
(defconstant +wm-syskeydown+               #x0104)
(defconstant +wm-syskeyup+                 #x0105)
(defconstant +wm-syschar+                  #x0106)
(defconstant +wm-sysdeadchar+              #x0107)
(defconstant +wm-keylast+                  #x0108)
(defconstant +wm-ime_startcomposition+     #x010D)
(defconstant +wm-ime_endcomposition+       #x010E)
(defconstant +wm-ime_composition+          #x010F)
(defconstant +wm-ime_keylast+              #x010F)
(defconstant +wm-initdialog+               #x0110)
(defconstant +wm-command+                  #x0111)
(defconstant +wm-syscommand+               #x0112)
(defconstant +wm-timer+                    #x0113)
(defconstant +wm-hscroll+                  #x0114)
(defconstant +wm-vscroll+                  #x0115)
(defconstant +wm-initmenu+                 #x0116)
(defconstant +wm-initmenupopup+            #x0117)
(defconstant +wm-menuselect+               #x011F)
(defconstant +wm-menuchar+                 #x0120)
(defconstant +wm-enteridle+                #x0121)
(defconstant +wm-ctlcolormsgbox+           #x0132)
(defconstant +wm-ctlcoloredit+             #x0133)
(defconstant +wm-ctlcolorlistbox+          #x0134)
(defconstant +wm-ctlcolorbtn+              #x0135)
(defconstant +wm-ctlcolordlg+              #x0136)
(defconstant +wm-ctlcolorscrollbar+        #x0137)
(defconstant +wm-ctlcolorstatic+           #x0138)
(defconstant +wm-mousefirst+               #x0200)
(defconstant +wm-mousemove+                #x0200)
(defconstant +wm-lbuttondown+              #x0201)
(defconstant +wm-lbuttonup+                #x0202)
(defconstant +wm-lbuttondblclk+            #x0203)
(defconstant +wm-rbuttondown+              #x0204)
(defconstant +wm-rbuttonup+                #x0205)
(defconstant +wm-rbuttondblclk+            #x0206)
(defconstant +wm-mbuttondown+              #x0207)
(defconstant +wm-mbuttonup+                #x0208)
(defconstant +wm-mbuttondblclk+            #x0209)
(defconstant +wm-mousewheel+               #x020A)
(defconstant +wm-mousehwheel+              #x020E)
(defconstant +wm-parentnotify+             #x0210)
(defconstant +wm-entermenuloop+            #x0211)
(defconstant +wm-exitmenuloop+             #x0212)
(defconstant +wm-nextmenu+                 #x0213)
(defconstant +wm-sizing+                   #x0214)
(defconstant +wm-capturechanged+           #x0215)
(defconstant +wm-moving+                   #x0216)
(defconstant +wm-powerbroadcast+           #x0218)
(defconstant +wm-devicechange+             #x0219)
(defconstant +wm-mdicreate+                #x0220)
(defconstant +wm-mdidestroy+               #x0221)
(defconstant +wm-mdiactivate+              #x0222)
(defconstant +wm-mdirestore+               #x0223)
(defconstant +wm-mdinext+                  #x0224)
(defconstant +wm-mdimaximize+              #x0225)
(defconstant +wm-mditile+                  #x0226)
(defconstant +wm-mdicascade+               #x0227)
(defconstant +wm-mdiiconarrange+           #x0228)
(defconstant +wm-mdigetactive+             #x0229)
(defconstant +wm-mdisetmenu+               #x0230)
(defconstant +wm-entersizemove+            #x0231)
(defconstant +wm-exitsizemove+             #x0232)
(defconstant +wm-dropfiles+                #x0233)
(defconstant +wm-mdirefreshmenu+           #x0234)
(defconstant +wm-ime-setcontext+           #x0281)
(defconstant +wm-ime-notify+               #x0282)
(defconstant +wm-ime-control+              #x0283)
(defconstant +wm-ime-compositionfull+      #x0284)
(defconstant +wm-ime-select+               #x0285)
(defconstant +wm-ime-char+                 #x0286)
(defconstant +wm-ime-keydown+              #x0290)
(defconstant +wm-ime-keyup+                #x0291)
(defconstant +wm-mousehover+               #x02A1)
(defconstant +wm-ncmouseleave+             #x02A2)
(defconstant +wm-mouseleave+               #x02A3)
(defconstant +wm-cut+                      #x0300)
(defconstant +wm-copy+                     #x0301)
(defconstant +wm-paste+                    #x0302)
(defconstant +wm-clear+                    #x0303)
(defconstant +wm-undo+                     #x0304)
(defconstant +wm-renderformat+             #x0305)
(defconstant +wm-renderallformats+         #x0306)
(defconstant +wm-destroyclipboard+         #x0307)
(defconstant +wm-drawclipboard+            #x0308)
(defconstant +wm-paintclipboard+           #x0309)
(defconstant +wm-vscrollclipboard+         #x030A)
(defconstant +wm-sizeclipboard+            #x030B)
(defconstant +wm-askcbformatname+          #x030C)
(defconstant +wm-changecbchain+            #x030D)
(defconstant +wm-hscrollclipboard+         #x030E)
(defconstant +wm-querynewpalette+          #x030F)
(defconstant +wm-paletteischanging+        #x0310)
(defconstant +wm-palettechanged+           #x0311)
(defconstant +wm-hotkey+                   #x0312)
(defconstant +wm-print+                    #x0317)
(defconstant +wm-printclient+              #x0318)
(defconstant +wm-handheldfirst+            #x0358)
(defconstant +wm-handheldlast+             #x035F)
(defconstant +wm-penwinfirst+              #x0380)
(defconstant +wm-penwinlast+               #x038F)
(defconstant +wm-coalesce_first+           #x0390)
(defconstant +wm-coalesce_last+            #x039F)
(defconstant +wm-dde-first+                #x03E0)
(defconstant +wm-dde-initiate+             #x03E0)
(defconstant +wm-dde-terminate+            #x03E1)
(defconstant +wm-dde-advise+               #x03E2)
(defconstant +wm-dde-unadvise+             #x03E3)
(defconstant +wm-dde-ack+                  #x03E4)
(defconstant +wm-dde-data+                 #x03E5)
(defconstant +wm-dde-request+              #x03E6)
(defconstant +wm-dde-poke+                 #x03E7)
(defconstant +wm-dde-execute+              #x03E8)
(defconstant +wm-dde-last+                 #x03E8)
(defconstant +wm-user+                     #x0400)
(defconstant +wm-app+                      #x8000)

(defconstant +time-cancel+    #x80000000)
(defconstant +time-hover+     #x00000001)
(defconstant +time-leave+     #x00000002)
(defconstant +time-nonclient+ #x80000010)
(defconstant +time-query+     #x40000000)

(defconstant +cw-usedefault+ (%to-int32 #x80000000))

(defconstant +cs-vredraw+ #x0001)
(defconstant +cs-hredraw+ #x0002)
(defconstant +cs-owndc+   #x0020)

(defconstant +sw-show+ 5)

(defvar +idi-application+ (make-pointer 32512))
(defvar +idc-arrow+ (make-pointer 32512))

(defconstant +white-brush+ 0)
(defconstant +black-brush+ 4)
(defconstant +dc-brush+ 18)

(defconstant +gcl-hbrbackground+ -10)
(defconstant +gcl-wndproc+ -24)

(defconstant +gcw-atom+ -32)

(defconstant +gwl-wndproc+  -4)
(defconstant +gwl-id+       -12)
(defconstant +gwl-style+    -16)
(defconstant +gwl-userdata+ -21)

(defconstant +swp-nosize+         #x0001)
(defconstant +swp-nomove+         #x0002)
(defconstant +swp-nozorder+       #x0004)
(defconstant +swp-noactivate+     #x0010)
(defconstant +swp-showwindow+     #x0040)
(defconstant +swp-hidewindow+     #x0080)
(defconstant +swp-noownerzorder+  #x0200)
(defconstant +swp-noreposition+   #x0200)

(defconstant +infinite+       #xFFFFFFFF)

(defconstant +wait-object-0+  #x00000000)
(defconstant +wait-abandoned+ #x00000080)
(defconstant +wait-timeout+   #x00000102)
(defconstant +wait-failed+    #xFFFFFFFF)

(defconstant +hwnd-top+       #x00000000)
(defconstant +hwnd-bottom+    #x00000001)
#+:x86
(progn
  (defconstant +hwnd-message+   #xFFFFFFFD)
  (defconstant +hwnd-notopmost+ #xFFFFFFFE)
  (defconstant +hwnd-topmost+   #xFFFFFFFF))

#+:x86-64
(progn
  (defconstant +hwnd-message+   #xFFFFFFFFFFFFFFFD)
  (defconstant +hwnd-notopmost+ #xFFFFFFFFFFFFFFFE)
  (defconstant +hwnd-topmost+   #xFFFFFFFFFFFFFFFF))

(defconstant +winevent-outofcontext+    #x0000)
(defconstant +winevent-skipownthread+   #x0001)
(defconstant +winevent-skipownprocess+  #x0002)
(defconstant +winevent-incontext+       #x0004)

(defconstant +wh-mouse+        7)
(defconstant +wh-mouse-ll+    14)

(defconstant +delete+         #x00010000)
(defconstant +read-control+   #x00020000)
(defconstant +write-dac+      #x00040000)
(defconstant +write-owner+    #x00080000)
(defconstant +synchronize+    #x00100000)

(defconstant +standard-rights-required+ #x00F0000)

(defconstant +standard-rights-read+     +read-control+)
(defconstant +standard-rights-write+    +read-control+)
(defconstant +standard-rights-execute+  +read-control+)

(defconstant +standard-rights-all+      #x001F0000)
(defconstant +specific-rights-all+      #x0000FFFF)

(defconstant +desktop-createmenu+      #x0004
  "Required to create a menu on the desktop.")
(defconstant +desktop-createwindow+    #x0002
  "Required to create a window on the desktop.")
(defconstant +desktop-enumerate+       #x0040
  "Required for the desktop to be enumerated.")
(defconstant +desktop-hookcontrol+     #x0008
  "Required to establish any of the window hooks.")
(defconstant +desktop-journalplayback+ #x0020
  "Required to perform journal playback on a desktop.")
(defconstant +desktop-journalrecord+   #x0010
  "Required to perform journal recording on a desktop.")
(defconstant +desktop-readobjects+     #x0001
  "Required to read objects on the desktop.")
(defconstant +desktop-switchdesktop+   #x0100
  "Required to activate the desktop using the SwitchDesktop function.")
(defconstant +desktop-writeobjects+    #x0080
  "Required to write objects on the desktop.")

(defconstant +generic-read+ (logior +desktop-enumerate+
                                    +desktop-readobjects+
                                    +standard-rights-read+))

(defconstant +generic-write+ (logior +desktop-createmenu+
                                     +desktop-createwindow+
                                     +desktop-hookcontrol+
                                     +desktop-journalplayback+
                                     +desktop-journalrecord+
                                     +desktop-writeobjects+
                                     +standard-rights-write+))

(defconstant +generic-execute+ (logior +desktop-switchdesktop+
                                       +standard-rights-execute+))

(defconstant +generic-all+ (logior +desktop-createmenu+
                                   +desktop-createwindow+
                                   +desktop-enumerate+
                                   +desktop-hookcontrol+
                                   +desktop-journalplayback+
                                   +desktop-journalrecord+
                                   +desktop-readobjects+
                                   +desktop-switchdesktop+
                                   +desktop-writeobjects+
                                   +standard-rights-required+))

(defconstant +movefile-replace-existing+      #x01)
(defconstant +movefile-copy-allowed+          #x02)
(defconstant +movefile-delay-until-reboot+    #x04)
(defconstant +movefile-write-through+         #x08)
(defconstant +movefile-create-hardlink+       #x10)
(defconstant +movefile-fail-if-not-trackable+ #x20)

(defconstant +copy-file-fail-if-exists+              #x00000001)
(defconstant +copy-file-restartable+                 #x00000002)
(defconstant +copy-file-open-source-for-write+       #x00000004)
(defconstant +copy-file-allow-decrypted-destination+ #x00000008)
(defconstant +copy-file-copy-symlink+                #x00000800)
(defconstant +copy-file-no-buffering+                #x00001000)


(defconstant +hkey-classes-root+        #x80000000)
(defconstant +hkey-current-user+        #x80000001)
(defconstant +hkey-local-machine+       #x80000002)
(defconstant +hkey-users+               #x80000003)
(defconstant +hkey-performance-data+    #x80000004)
(defconstant +hkey-current-config+      #x80000005)
(defconstant +hkey-dyn-data+            #x80000006)
(defconstant +hkey-performance-text+    #x80000050)
(defconstant +hkey-performance-nlstext+ #x80000060)

(defconstant +reg-none+ 0)
(defconstant +reg-sz+ 1)
(defconstant +reg-expand-sz+ 2)
(defconstant +reg-binary+ 3)
(defconstant +reg-dword+ 4)
(defconstant +reg-dword-little-endian+ 4)
(defconstant +reg-dword-big-endian+ 5)
(defconstant +reg-link+ 6)
(defconstant +reg-multi-sz+ 7)
(defconstant +reg-resource-list+ 8)
(defconstant +reg-full-resource-descriptor+ 9)
(defconstant +reg-resource-requirements-list+ 10)
(defconstant +reg-qword+ 11)
(defconstant +reg-qword-little-endian+ 11)

(defconstant +rrf-rt-any+           #x0000ffff)
(defconstant +rrf-rt-dword+         #x00000018)
(defconstant +rrf-rt-qword+         #x00000048)
(defconstant +rrf-rt-reg-binary+    #x00000008)
(defconstant +rrf-rt-reg-dword+     #x00000010)
(defconstant +rrf-rt-reg-expand-sz+ #x00000004)
(defconstant +rrf-rt-reg-multi-sz+  #x00000020)
(defconstant +rrf-rt-reg-none+      #x00000001)
(defconstant +rrf-rt-reg-qword+     #x00000040)
(defconstant +rrf-rt-reg-sz+        #x00000002)

(defconstant +rrf-noexpand+          #x10000000)
(defconstant +rrf-zeroonfailure+     #x20000000)
(defconstant +rrf-subkey-wow6464key+ #x00010000)
(defconstant +rrf-subkey-wow6432key+ #x00020000)

(defconstant +reg-option-reserved+       #x00000000)
(defconstant +reg-option-backup-restore+ #x00000004)
(defconstant +reg-option-create-link+    #x00000002)
(defconstant +reg-option-non-volatile+   #x00000000)
(defconstant +reg-option-volatile+       #x00000001)
(defconstant +reg-option-open-link+      #x00000008)

(defconstant +reg-created-new-key+     #x00000001)
(defconstant +reg-opened-existing-key+ #x00000002)

(defconstant +key-all-access+         #xF003F)
(defconstant +key-create-link+        #x00020)
(defconstant +key-create-sub-key+     #x00004)
(defconstant +key-enumerate-sub-keys+ #x00008)
(defconstant +key-execute+            #x20019)
(defconstant +key-notify+             #x00010)
(defconstant +key-query-value+        #x00001)
(defconstant +key-read+               #x20019)
(defconstant +key-set-value+          #x00002)
(defconstant +key-wow64-32key+        #x00200)
(defconstant +key-wow64-64key+        #x00100)
(defconstant +key-write+              #x20006)

(defconstant +color-3ddkshadow+ 21)
(defconstant +color-3dface+ 15)
(defconstant +color-3dhighlight+ 20)
(defconstant +color-3dhilight+ 20)
(defconstant +color-3dlight+ 22)
(defconstant +color-3dshadow+ 16)
(defconstant +color-activeborder+ 10)
(defconstant +color-activecaption+ 2)
(defconstant +color-appworkspace+ 12)
(defconstant +color-background+ 1)
(defconstant +color-btnface+ 15)
(defconstant +color-btnhighlight+ 20)
(defconstant +color-btnhilight+ 20)
(defconstant +color-btnshadow+ 16)
(defconstant +color-btntext+ 18)
(defconstant +color-captiontext+ 9)
(defconstant +color-desktop+ 1)
(defconstant +color-gradientactivecaption+ 27)
(defconstant +color-gradientinactivecaption+ 28)
(defconstant +color-graytext+ 17)
(defconstant +color-highlight+ 13)
(defconstant +color-highlighttext+ 14)
(defconstant +color-hotlight+ 26)
(defconstant +color-inactiveborder+ 11)
(defconstant +color-inactivecaption+ 3)
(defconstant +color-inactivecaptiontext+ 19)
(defconstant +color-infobk+ 24)
(defconstant +color-infotext+ 23)
(defconstant +color-menu+ 4)
(defconstant +color-menuhilight+ 29)
(defconstant +color-menubar+ 30)
(defconstant +color-menutext+ 7)
(defconstant +color-scrollbar+ 0)
(defconstant +color-window+ 5)
(defconstant +color-windowframe+ 6)
(defconstant +color-windowtext+ 8)

(defconstant +smto-abortifhung+        #x0002)
(defconstant +smto-block+              #x0001)
(defconstant +smto-normal+             #x0000)
(defconstant +smto-notimeoutifnothung+ #x0008)
(defconstant +smto-erroronexit+        #x0020)

(defconstant +bsf-allowsfw+           #x00000080)
(defconstant +bsf-flushdisk+          #x00000004)
(defconstant +bsf-forceifhung+        #x00000020)
(defconstant +bsf-ignorecurrenttask+  #x00000002)
(defconstant +bsf-luid+               #x00000400)
(defconstant +bsf-nohang+             #x00000008)
(defconstant +bsf-notimeoutifnothung+ #x00000040)
(defconstant +bsf-postmessage+        #x00000010)
(defconstant +bsf-returnhdesk+        #x00000200)
(defconstant +bsf-query+              #x00000001)
(defconstant +bsf-sendnotifymessage+  #x00000100)

(defconstant +bsm-allcomponents+ #x00000000)
(defconstant +bsm-alldesktops+   #x00000010)
(defconstant +bsm-applications+  #x00000008)

(defconstant +ismex-callback+ #x00000004)
(defconstant +ismex-notify+   #x00000002)
(defconstant +ismex-replied+  #x00000008)
(defconstant +ismex-send+     #x00000001)

(defcstruct unicode-string
  (length ushort)
  (maximum-length ushort)
  (buffer pwstr))

(defcstruct luid
  (low-part dword)
  (high-part long))

(defcstruct bsminfo
  (size uint)
  (hdesk hdesk)
  (hwnd hwnd)
  (luid (:struct luid)))

(defcstruct rect
  (left :int32)
  (top :int32)
  (right :int32)
  (bottom :int32))

(defcstruct paletteentry
  (red :uint8)
  (green :uint8)
  (blue :uint8)
  (flags :uint8))

(defcstruct paintstruct
  (dc :pointer)
  (erase :boolean)
  (paint (:struct rect))
  (restore :boolean)
  (incupdate :boolean)
  (rgbreserved :uint8 :count 32))

(defcstruct logpalette
  (version :uint16)
  (num-entries :uint16)
  (palette-entries (:struct paletteentry) :count 1))

(defcstruct pixelformatdescriptor
  (size :uint16)
  (version :uint16)
  (flags :uint32)
  (pixel-type :uint8)
  (color-bits :uint8)
  (red-bits :uint8)
  (red-shift :uint8)
  (green-bits :uint8)
  (green-shift :uint8)
  (blue-bits :uint8)
  (blue-shift :uint8)
  (alpha-bits :uint8)
  (alpha-shift :uint8)
  (accum-bits :uint8)
  (accum-red-bits :uint8)
  (accum-green-bits :uint8)
  (accum-blue-bits :uint8)
  (accum-alpha-bits :uint8)
  (depth-bits :uint8)
  (stencil-bits :uint8)
  (aux-buffers :uint8)
  (layer-type :uint8)
  (reserved :uint8)
  (layer-mask :uint32)
  (visible-mask :uint32)
  (damage-mask :uint32))

(defcstruct point
  (x :int32)
  (y :int32))

(defcstruct trackmouseevent
  (cbsize :uint32)
  (flags :uint32)
  (hwnd :pointer)
  (hover-time :uint32))

(defcstruct wndclass
  (style :uint32)
  (wndproc :pointer)
  (clsextra :int32)
  (wndextra :int32)
  (instance :pointer)
  (icon :pointer)
  (cursor :pointer)
  (background :pointer)
  (menu-name (:string :encoding #.+win32-string-encoding+))
  (wndclass-name (:string :encoding #.+win32-string-encoding+)))

(defcstruct wndclassex
  (cbsize :uint32)
  (style :uint32)
  (wndproc :pointer)
  (clsextra :int32)
  (wndextra :int32)
  (instance :pointer)
  (icon :pointer)
  (cursor :pointer)
  (background :pointer)
  (menu-name (:string :encoding #.+win32-string-encoding+))
  (wndclass-name (:string :encoding #.+win32-string-encoding+))
  (iconsm :pointer))

(defcstruct msg
  (hwnd :pointer)
  (message :uint32)
  (wparam :pointer)
  (lparam :pointer)
  (time :uint32)
  (point (:struct point)))

(defcstruct createstruct
  (create-params :pointer)
  (instance :pointer)
  (menu :pointer)
  (parent :pointer)
  (cy :int)
  (cx :int)
  (y :int)
  (x :int)
  (style :long)
  (name (:string :encoding #.+win32-string-encoding+))
  (class (:string :encoding #.+win32-string-encoding+))
  (exstyle :uint32))

(defcstruct overlapped
  (internal :pointer)
  (internal-high :pointer)
  (offset :uint32)
  (offset-high :uint32)
  (event :pointer))

(defcstruct security-attributes
  (length :uint32)
  (security-descriptor :pointer)
  (inherit :boolean))

(defcfun ("Beep" beep) :boolean
  (frequency :uint32)
  (duration :uint32))

(defcfun ("BeginPaint" begin-paint) :pointer
  (hwnd :pointer)
  (paint :pointer))

(defcfun ("BroadcastSystemMessageW" broadcast-system-message) :long
  (flags dword)
  (recipients (:pointer dword))
  (message uint)
  (wparam wparam)
  (lparam lparam))

(defcfun ("BroadcastSystemMessageExW" broadcast-system-message) :long
  (flags dword)
  (recipients (:pointer dword))
  (message uint)
  (wparam wparam)
  (lparam lparam)
  (bsminfo (:pointer (:struct bsminfo))))

(defcfun ("CallNextHookEx" call-next-hook) :uint32
  (current-hook :pointer)
  (code :int32)
  (wparam :uint32)
  (lparam :uint32))

(defcfun ("CallWindowProcW" call-window-proc) lresult
  (prev-wndproc :pointer)
  (hwnd hwnd)
  (msg uint)
  (wparam wparam)
  (lparam lparam))

(defcfun ("CancelIo" cancel-io) :int
  (handle :pointer))

(defcfun ("ChoosePixelFormat" choose-pixel-format) :int
  (dc :pointer)
  (pixel-format :pointer))

(defcfun ("ClientToScreen" client-to-screen) :boolean
  (hwnd :pointer)
  (point :pointer))

(defcfun ("ClipCursor" clip-cursor) :boolean
  (rect :pointer))

(defcfun ("CloseHandle" close-handle) :boolean
  (handle :pointer))

(defcfun ("CloseWindow" close-window) :boolean
  (hwnd :pointer))

(defcfun ("CopyFileW" copy-file) :boolean
  (existing-name (:string :encoding #.+win32-string-encoding+))
  (new-name (:string :encoding #.+win32-string-encoding+))
  (fail-if-exists :boolean))

(defcfun ("CopyFileExW" copy-file-ex) :boolean
  (existing-name (:string :encoding #.+win32-string-encoding+))
  (new-name (:string :encoding #.+win32-string-encoding+))
  (progress-routine :pointer)
  (data :pointer)
  (cancel :pointer)
  (flags :uint32))

(defcfun ("CreateDesktopW" create-desktop) :pointer
  (desktop (:string :encoding #.+win32-string-encoding+))
  (device :pointer)
  (devmode :pointer)
  (flags :uint32)
  (desired-access :uint32)
  (security-attributes :pointer))

(defcfun ("CreateEventW" create-event) :pointer
  (security-attributes :pointer)
  (manual-reset :boolean)
  (initial-state :boolean)
  (name (:string :encoding #.+win32-string-encoding+)))

(defcfun ("CreateFileW" create-file) :pointer
  (path (:string :encoding #.+win32-string-encoding+))
  (file-access :uint)
  (share-access :uint)
  (security :pointer)
  (file-mode :uint)
  (flags :uint)
  (template :pointer))

(defcfun ("CreateMutexW" create-mutex) :pointer
  (security-attributes :pointer)
  (initial-owner :boolean)
  (name (:string :encoding #.+win32-string-encoding+)))

(defcfun ("CreatePalette" create-palette) :pointer
  (log-palette :pointer))

(defcfun ("CreateSemaphoreW" create-semaphore) :pointer
  (security-attributes :pointer)
  (initial-count :int32)
  (maximum-count :int32)
  (name (:string :encoding #.+win32-string-encoding+)))

(defcfun ("CreateWindowExW" create-window-ex) :pointer
  (ex-style :uint32)
  (wndclass-name (:string :encoding #.+win32-string-encoding+))
  (window-name (:string :encoding #.+win32-string-encoding+))
  (style :uint32)
  (x :int32)
  (y :int32)
  (width :int32)
  (height :int32)
  (parent :pointer)
  (menu :pointer)
  (module-instance :pointer)
  (param :pointer))

(defcfun ("DefWindowProcW" def-window-proc) lresult
  (hwnd hwnd)
  (msg uint)
  (wparam wparam)
  (lparam lparam))

(defcfun ("DeleteObject" delete-object) :int
  (object :pointer))

(defcfun ("DescribePixelFormat" describe-pixel-format) :int
  (dc :pointer)
  (format-index :int)
  (bytes :uint32)
  (pixel-format :pointer))

(defcfun ("DestroyCursor" destroy-cursor) :boolean
  (cursor :pointer))

(defcfun ("DestroyWindow" destroy-window) :boolean
  (hwnd :pointer))

(defcfun ("DispatchMessageW" dispatch-message) :int32
  (msg :pointer))

(defcfun ("EnableWindow" enable-window) :boolean
  (hwnd :pointer)
  (enable :boolean))

(defcfun ("EndPaint" end-paint) :boolean
  (hwnd :pointer)
  (paint :pointer))

(defcfun ("EnumWindows" enum-windows) :boolean
  (callback :pointer)
  (lparam :pointer))

(defcfun ("FindWindowW" find-window) :pointer
  (wndclass-name (:string :encoding #.+win32-string-encoding+))
  (window-name (:string :encoding #.+win32-string-encoding+)))

(defcfun ("GetClassLongW" get-class-long) :long
  (hwnd :pointer)
  (index :int))

#+x86
(defcfun ("GetClassLongW" get-class-long-ptr) :pointer
  (hwnd :pointer)
  (index :int))

#+x86-64
(defcfun ("GetClassLongPtrW" get-class-long-ptr) :pointer
  (hwnd :pointer)
  (index :int))

(defcfun ("GetClassWord" get-class-word) :uint16
  (hwnd :pointer)
  (index :int))

(defcfun ("GetClientRect" get-client-rect) :boolean
  (hwnd :pointer)
  (rect :pointer))

(defcfun ("GetCommandLineW" get-command-line)
    (:string :encoding #.+win32-string-encoding+))

(defcfun ("GetCurrentProcess" get-current-process) :pointer)

(defcfun ("GetCurrentProcessId" get-current-process-id) :uint32)

(defcfun ("GetCurrentProcessorNumber" get-current-processor-number)
    :uint32)

(defcfun ("GetCurrentThreadId" get-current-thread-id) :uint32)

(defcfun ("GetDC" get-dc) :pointer
  (hwnd :pointer))

(defcfun ("GetDesktopWindow" get-desktop-window) :pointer)

(defcfun ("GetInputState" get-input-state) bool)

(defcfun ("GetLastError" get-last-error) :uint32)

(defcfun ("GetMessageW" get-message) :boolean
  (msg :pointer)
  (hwnd :pointer)
  (msg-min :uint32)
  (msg-max :uint32))

(defcfun ("GetMessageExtraInfo" get-message-extra-info) lparam)

(defcfun ("GetMessagePos" get-message-pos) dword)

(defcfun ("GetMessageTime" get-message-time) long)

(defcfun ("GetModuleHandleW" get-module-handle) :pointer
  (module (:string :encoding #.+win32-string-encoding+)))

(defcfun ("GetOverlappedResult" get-overlapped-result) :int
  (handle :pointer)
  (overlapped (:pointer (:struct overlapped)))
  (bytes-transfered (:pointer :uint32))
  (wait :int))

(defcfun ("GetParent" get-parent) :pointer
  (hwnd :pointer))

(defcfun ("GetPixelFormat" get-pixel-format) :int
  (dc :pointer))

(defcfun ("GetShellWindow" get-shell-window) :pointer)

(defcfun ("GetStockObject" get-stock-object) :pointer
  (object :uint32))

(defcfun ("GetQueueStatus" get-queue-status) dword
  (flags uint))

(defcfun ("GetSysColor" get-sys-color) :uint32
  (index :int))

(defcfun ("GetTopWindow" get-top-window) :pointer
  (hwnd :pointer))

(defcfun ("GetWindowLongW" get-window-long) :int32
  (hwnd :pointer)
  (index :int32))

(defcfun ("GetWindowRect" get-window-rect) :boolean
  (hwnd :pointer)
  (rect :pointer))

(defcfun ("GetWindowTextW" get-window-text) :int
  (hwnd :pointer)
  (string (:string :encoding #.+win32-string-encoding+))
  (size :int))

(defcfun ("GetWindowThreadProcessId" get-window-thread-process-id) :uint32
  (hwnd :pointer)
  (process-id :pointer))

(defcfun ("InSendMessage" in-send-message) bool)

(defcfun ("InSendMessageEx" in-send-message-ex) dword
  (reserved :pointer))

(defcfun ("InvalidateRect" invalidate-rect) :boolean
  (hwnd :pointer)
  (rect :pointer)
  (erase :boolean))

(defcfun ("IsGUIThread" is-gui-thread) :boolean
  (convert :boolean))

(defcfun ("IsWindow" is-window) :boolean
  (hwnd :pointer))

(defcfun ("LoadCursorW" load-cursor) :pointer
  (instance :pointer)
  (name (:string :encoding #.+win32-string-encoding+)))

(defcfun ("LoadCursorFromFileW" load-cursor-from-file) :pointer
  (file-name (:string :encoding #.+win32-string-encoding+)))

(defcfun ("LoadIconW" load-icon) :pointer
  (instance :pointer)
  (name (:string :encoding #.+win32-string-encoding+)))

(defcfun ("MoveFileW" move-file) :boolean
  (old-name (:string :encoding #.+win32-string-encoding+))
  (new-name (:string :encoding #.+win32-string-encoding+)))

(defcfun ("MoveFileExW" move-file-ex) :boolean
  (old-name (:string :encoding #.+win32-string-encoding+))
  (new-name (:string :encoding #.+win32-string-encoding+))
  (flags :uint32))

(defcfun ("OpenEventW" open-event) :pointer
  (access :uint32)
  (inherit-handle :boolean)
  (name (:string :encoding #.+win32-string-encoding+)))

(defcfun ("OpenInputDesktop" open-input-desktop) :pointer
  (flags :uint32)
  (inherit :boolean)
  (desired-access :uint32))

(defcfun ("PeekMessageW" peek-message) :int
  (msg :pointer)
  (hwnd :pointer)
  (msg-min :uint32)
  (msg-max :uint32)
  (remove :uint32))

(defcfun ("PostMessageW" post-message) :boolean
  (hwnd :pointer)
  (msg :uint32)
  (wparam :pointer)
  (lparam :pointer))

(defcfun ("PostQuitMessage" post-quit-message) :void
  (exit-code :int32))

(defcfun ("PostThreadMessageW" post-thread-message) :boolean
  (thread-id :uint32)
  (msg :uint32)
  (wparam :pointer)
  (lparam :pointer))

(defcfun ("ReadFile" read-file) :int
  (handle :pointer)
  (buffer :pointer)
  (bytes-to-read :uint32)
  (bytes-read (:pointer :uint32))
  (overlapped (:pointer (:struct overlapped))))

(defcfun ("RealizePalette" realize-palette) :uint32
  (dc :pointer))

(defcfun ("RegCloseKey" reg-close-key) :long
  (hkey :pointer))

(defcfun ("RegCreateKeyW" reg-create-key) :long
  (hkey :pointer)
  (sub-key (:string :encoding #.+win32-string-encoding+))
  (phkey-result (:pointer :pointer)))

(defcfun ("RegCreateKeyExW" reg-create-key-ex) :long
  (hkey :pointer)
  (sub-key (:string :encoding #.+win32-string-encoding+))
  (reserved :uint32)
  (class (:string :encoding #.+win32-string-encoding+))
  (options :uint32)
  (sam-desired :uint32)
  (security-attributes (:pointer (:struct security-attributes)))
  (phkey-result (:pointer :pointer))
  (disposition (:pointer :uint32)))

(defcfun ("RegDeleteKeyW" reg-delete-key) :long
  (hkey :pointer)
  (sub-key (:string :encoding #.+win32-string-encoding+)))

(defcfun ("RegDeleteKeyExW" reg-delete-key-ex) :long
  (hkey :pointer)
  (sub-key (:string :encoding #.+win32-string-encoding+))
  (sam-desired :uint32)
  (reserved :uint32))

(defcfun ("RegDeleteTreeW" reg-delete-tree) :long
  (hkey :pointer)
  (sub-key (:string :encoding #.+win32-string-encoding+)))

(defcfun ("RegGetValueW" reg-get-value) :long
  (hkey :pointer)
  (sub-key (:string :encoding #.+win32-string-encoding+))
  (value-name (:string :encoding #.+win32-string-encoding+))
  (flags :uint32)
  (type (:pointer :uint32))
  (data :pointer)
  (data-size (:pointer :uint32)))

(defcfun ("RegOpenKeyW" reg-open-key) :long
  (hkey :pointer)
  (sub-key (:string :encoding #.+win32-string-encoding+))
  (phkey-result (:pointer :pointer)))

(defcfun ("RegOpenKeyExW" reg-open-key-ex) :long
  (hkey :pointer)
  (sub-key (:string :encoding #.+win32-string-encoding+))
  (options :uint32)
  (sam-desired :uint32)
  (phkey-result (:pointer :pointer)))

(defcfun ("RegQueryValueW" reg-query-value) :long
  (hkey :pointer)
  (sub-key (:string :encoding #.+win32-string-encoding+))
  (value (:pointer (:string :encoding #.+win32-string-encoding+)))
  (value-size (:pointer :long)))

(defcfun ("RegQueryValueExW" reg-query-value-ex) :long
  (hkey :pointer)
  (value-name (:string :encoding #.+win32-string-encoding+))
  (reserved (:pointer :uint32))
  (type (:pointer :uint32))
  (data (:pointer :uint8))
  (data-size (:pointer :uint32)))

(defcfun ("RegSetValueW" reg-set-value) :long
  (hkey :pointer)
  (sub-key (:string :encoding #.+win32-string-encoding+))
  (type :uint32)
  (data (:string :encoding #.+win32-string-encoding+))
  (data-size :uint32))

(defcfun ("RegSetValueExW" reg-set-value-ex) :long
  (hkey :pointer)
  (value-name (:string :encoding #.+win32-string-encoding+))
  (reserved :uint32)
  (type :uint32)
  (data (:pointer :uint8))
  (data-size :uint32))

(defcfun ("RegisterClassW" register-class) :uint16
  (wndclass :pointer))

(defcfun ("RegisterClassExW" register-class-ex) :uint16
  (wndclassex :pointer))

(defcfun ("RegisterWindowMessageW" register-window-message) uint
  (string lpctstr))

(defcfun ("ReleaseDC" release-dc) :boolean
  (hwnd :pointer)
  (dc :pointer))

(defcfun ("ReplyMessage" reply-message) bool
  (result lresult))

(defcfun ("ResetEvent" reset-event) :boolean
  (event :pointer))

(defcfun ("ResizePalette" resize-palette) :boolean
  (palette :pointer)
  (entries :int))

(defun rgb (r g b)
  (logior (ash b 16)
          (ash g 8)
          (ash r 0)))

(defcfun ("SelectPalette" select-palette) :pointer
  (dc :pointer)
  (palette :pointer)
  (force-background :boolean))

(defcfun ("SendInput" send-input) :uint32
  (num-inputs :uint32)
  (inputs :pointer)
  (cbsize :int))

(defcfun ("SendMessageW" send-message) lresult
  (hwnd hwnd)
  (msg uint)
  (wparam wparam)
  (lparam lparam))

(defcfun ("SendMessageCallbackW" send-message-callback) bool
  (hwnd hwnd)
  (msg uint)
  (wparam wparam)
  (lparam lparam)
  (callback :pointer)
  (data ulong-ptr))

(defcfun ("SendMessageTimeout" send-message-timeout) lresult
  (hwnd hwnd)
  (msg uint)
  (wparam wparam)
  (flags uint)
  (timeout uint)
  (result (:pointer dword-ptr)))

(defcfun ("SendNotifyMessageW" send-notify-message) bool
  (hwnd hwnd)
  (msg uint)
  (wparam wparam)
  (lparam lparam))

(defcfun ("SetClassLongW" set-class-long) :uint32
  (hwnd :pointer)
  (index :int)
  (value :long))

#+x86
(defcfun ("SetClassLongW" set-class-long-ptr) :pointer
  (hwnd :pointer)
  (index :int)
  (value :pointer))

#+x86-64
(defcfun ("SetClassLongPtrW" set-class-long-ptr) :pointer
  (hwnd :pointer)
  (index :int)
  (value :pointer))

(defcfun ("SetClassWord" set-class-word) :pointer
  (hwnd :pointer)
  (index :int)
  (value :uint16))

(defcfun ("SetCursor" set-cursor) :pointer
  (cursor :pointer))

(defcfun ("SetCursorPos" set-cursor-pos) :boolean
  (x :int)
  (y :int))

(defcfun ("SetEvent" set-event) :boolean
  (event :pointer))

(defcfun ("SetForegroundWindow" set-foreground-window) :boolean
  (hwnd :pointer))

(defcfun ("SetLayeredWindowAttributes" set-layered-window-attributes) :boolean
  (hwnd :pointer)
  (color :uint32)
  (alpha :uint8)
  (flags :uint32))

(defcfun ("SetMessageExtraInfo" set-message-extra-info) lparam
  (lparam lparam))

(defcfun ("SetParent" set-parent) :boolean
  (hwnd :pointer)
  (new-parent :pointer))

(defcfun ("SetPixelFormat" set-pixel-format) :boolean
  (dc :pointer)
  (format-index :int)
  (pixel-format :pointer))

(defcfun ("SetWinEventHook" set-win-event-hook) :pointer
  (event-min :uint32)
  (event-max :uint32)
  (proc-module :pointer)
  (id-process :uint32)
  (id-thread :uint32)
  (flags :uint32))

(defcfun ("SetWindowLongW" set-window-long) :int32
  (hwnd :pointer)
  (index :int32)
  (newval :int32))

(defcfun ("SetWindowPos" set-window-pos) :boolean
  (hwnd :pointer)
  (insert-after :pointer)
  (x :int32)
  (y :int32)
  (cx :int32)
  (cy :int32)
  (flags :uint32))

(defcfun ("SetWindowTextW" set-window-text) :boolean
  (hwnd :pointer)
  (text (:string :encoding #.+win32-string-encoding+)))

(defcfun ("SetWindowsHookExW" set-windows-hook-ex) :pointer
  (id-hook :int32)
  (hook :pointer)
  (module :pointer)
  (thread-id :uint32))

(defcfun ("ShowCursor" show-cursor) :int
  (show :boolean))

(defcfun ("ShowWindow" show-window) :int
  (hwnd :pointer)
  (cmd :int32))

(defcfun ("SwapBuffers" swap-buffers) :boolean
  (dc :pointer))

(defcfun ("SwitchDesktop" switch-desktop) :boolean
  (desktop :pointer))

(defcfun ("TrackMouseEvent" track-mouse-event) :boolean
  (trackmousevent :pointer))

(defcfun ("TranslateMessage" translate-message) :int
  (msg :pointer))

(defcfun ("UnregisterClassW" unregister-class) :boolean
  (wndclass-name (:string :encoding #.+win32-string-encoding+))
  (instance :pointer))

(defcfun ("UpdateWindow" update-window) :int
  (hwnd :pointer))

(defcfun ("ValidateRect" validate-rect) :boolean
  (hwnd :pointer)
  (rect :pointer))

(defcfun ("WaitForSingleObject" wait-for-single-object) :uint32
  (handle :pointer)
  (milliseconds :uint32))

(defcfun ("wglCreateContext" wgl-create-context) :pointer
  (dc :pointer))

(defcfun ("wglDeleteContext" wgl-delete-context) :boolean
  (context :pointer))

(defcfun ("wglMakeCurrent" wgl-make-current) :boolean
  (dc :pointer)
  (gl-rc :pointer))

;;;TODO This function actually takes in a struct point, but we need cffi-libffi for that
(defcfun ("WindowFromPoint" window-from-point) :pointer
  (x :int32)
  (y :int32))

(defcfun ("WriteFile" hid_write-file) :int
  (handle :pointer)
  (buffer :pointer)
  (bytes-to-write :uint32)
  (bytes-written (:pointer :uint32))
  (overlapped (:pointer (:struct overlapped))))
