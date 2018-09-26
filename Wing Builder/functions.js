"use strict";
var dat = dat || {};
dat.gui = dat.gui || {}, dat.utils = dat.utils || {}, dat.controllers = dat.controllers || {}, dat.dom = dat.dom || {}, dat.color = dat.color || {}, dat.utils.css = function () {
        return {
            load: function (a, b) {
                b = b || document;
                var c = b.createElement("link");
                c.type = "text/css", c.rel = "stylesheet", c.href = a, b.getElementsByTagName("head")[0].appendChild(c)
            },
            inject: function (a, b) {
                b = b || document;
                var c = document.createElement("style");
                c.type = "text/css", c.innerHTML = a, b.getElementsByTagName("head")[0].appendChild(c)
            }
        }
    }(), dat.utils.common = function () {
        var a = Array.prototype.forEach,
            b = Array.prototype.slice;
        return {
            BREAK: {},
            extend: function (a) {
                return this.each(b.call(arguments, 1), function (b) {
                    for (var c in b) this.isUndefined(b[c]) || (a[c] = b[c])
                }, this), a
            },
            defaults: function (a) {
                return this.each(b.call(arguments, 1), function (b) {
                    for (var c in b) this.isUndefined(a[c]) && (a[c] = b[c])
                }, this), a
            },
            compose: function () {
                var a = b.call(arguments);
                return function () {
                    for (var c = b.call(arguments), d = a.length - 1; d >= 0; d--) c = [a[d].apply(this, c)];
                    return c[0]
                }
            },
            each: function (b, c, d) {
                if (b)
                    if (a && b.forEach && b.forEach === a) b.forEach(c, d);
                    else if (b.length === b.length + 0)
                    for (var e = 0, f = b.length; f > e && !(e in b && c.call(d, b[e], e) === this.BREAK); e++);
                else
                    for (e in b)
                        if (c.call(d, b[e], e) === this.BREAK) break
            },
            defer: function (a) {
                setTimeout(a, 0)
            },
            toArray: function (a) {
                return a.toArray ? a.toArray() : b.call(a)
            },
            isUndefined: function (a) {
                return void 0 === a
            },
            isNull: function (a) {
                return null === a
            },
            isNaN: function (a) {
                return a !== a
            },
            isArray: Array.isArray || function (a) {
                return a.constructor === Array
            },
            isObject: function (a) {
                return a === Object(a)
            },
            isNumber: function (a) {
                return a === a + 0
            },
            isString: function (a) {
                return a === a + ""
            },
            isBoolean: function (a) {
                return !1 === a || !0 === a
            },
            isFunction: function (a) {
                return "[object Function]" === Object.prototype.toString.call(a)
            }
        }
    }(), dat.controllers.Controller = function (a) {
        var b = function (a, b) {
            this.initialValue = a[b], this.domElement = document.createElement("div"), this.object = a, this.property = b, this.__onFinishChange = this.__onChange = void 0
        };
        return a.extend(b.prototype, {
            onChange: function (a) {
                return this.__onChange = a, this
            },
            onFinishChange: function (a) {
                return this.__onFinishChange = a, this
            },
            setValue: function (a) {
                return this.object[this.property] = a, this.__onChange && this.__onChange.call(this, a), this.updateDisplay(), this
            },
            getValue: function () {
                return this.object[this.property]
            },
            updateDisplay: function () {
                return this
            },
            isModified: function () {
                return this.initialValue !== this.getValue()
            }
        }), b
    }(dat.utils.common), dat.dom.dom = function (a) {
        function b(b) {
            return "0" === b || a.isUndefined(b) ? 0 : (b = b.match(d), a.isNull(b) ? 0 : parseFloat(b[1]))
        }
        var c = {};
        a.each({
            HTMLEvents: ["change"],
            MouseEvents: ["click", "mousemove", "mousedown", "mouseup", "mouseover"],
            KeyboardEvents: ["keydown"]
        }, function (b, d) {
            a.each(b, function (a) {
                c[a] = d
            })
        });
        var d = /(\d+(\.\d+)?)px/,
            e = {
                makeSelectable: function (a, b) {
                    void 0 !== a && void 0 !== a.style && (a.onselectstart = b ? function () {
                        return !1
                    } : function () {}, a.style.MozUserSelect = b ? "auto" : "none", a.style.KhtmlUserSelect = b ? "auto" : "none", a.unselectable = b ? "on" : "off")
                },
                makeFullscreen: function (b, c, d) {
                    a.isUndefined(c) && (c = !0), a.isUndefined(d) && (d = !0), b.style.position = "absolute", c && (b.style.left = 0, b.style.right = 0), d && (b.style.top = 0, b.style.bottom = 0)
                },
                fakeEvent: function (b, d, e, f) {
                    e = e || {};
                    var g = c[d];
                    if (!g) throw Error("Event type " + d + " not supported.");
                    var h = document.createEvent(g);
                    switch (g) {
                        case "MouseEvents":
                            h.initMouseEvent(d, e.bubbles || !1, e.cancelable || !0, window, e.clickCount || 1, 0, 0, e.x || e.clientX || 0, e.y || e.clientY || 0, !1, !1, !1, !1, 0, null);
                            break;
                        case "KeyboardEvents":
                            g = h.initKeyboardEvent || h.initKeyEvent, a.defaults(e, {
                                cancelable: !0,
                                ctrlKey: !1,
                                altKey: !1,
                                shiftKey: !1,
                                metaKey: !1,
                                keyCode: void 0,
                                charCode: void 0
                            }), g(d, e.bubbles || !1, e.cancelable, window, e.ctrlKey, e.altKey, e.shiftKey, e.metaKey, e.keyCode, e.charCode);
                            break;
                        default:
                            h.initEvent(d, e.bubbles || !1, e.cancelable || !0)
                    }
                    a.defaults(h, f), b.dispatchEvent(h)
                },
                bind: function (a, b, c, d) {
                    return a.addEventListener ? a.addEventListener(b, c, d || !1) : a.attachEvent && a.attachEvent("on" + b, c), e
                },
                unbind: function (a, b, c, d) {
                    return a.removeEventListener ? a.removeEventListener(b, c, d || !1) : a.detachEvent && a.detachEvent("on" + b, c), e
                },
                addClass: function (a, b) {
                    if (void 0 === a.className) a.className = b;
                    else if (a.className !== b) {
                        var c = a.className.split(/ +/); - 1 == c.indexOf(b) && (c.push(b), a.className = c.join(" ").replace(/^\s+/, "").replace(/\s+$/, ""))
                    }
                    return e
                },
                removeClass: function (a, b) {
                    if (b) {
                        if (void 0 !== a.className)
                            if (a.className === b) a.removeAttribute("class");
                            else {
                                var c = a.className.split(/ +/),
                                    d = c.indexOf(b); - 1 != d && (c.splice(d, 1), a.className = c.join(" "))
                            }
                    } else a.className = void 0;
                    return e
                },
                hasClass: function (a, b) {
                    return new RegExp("(?:^|\\s+)" + b + "(?:\\s+|$)").test(a.className) || !1
                },
                getWidth: function (a) {
                    return a = getComputedStyle(a), b(a["border-left-width"]) + b(a["border-right-width"]) + b(a["padding-left"]) + b(a["padding-right"]) + b(a.width)
                },
                getHeight: function (a) {
                    return a = getComputedStyle(a), b(a["border-top-width"]) + b(a["border-bottom-width"]) + b(a["padding-top"]) + b(a["padding-bottom"]) + b(a.height)
                },
                getOffset: function (a) {
                    var b = {
                        left: 0,
                        top: 0
                    };
                    if (a.offsetParent)
                        do b.left += a.offsetLeft, b.top += a.offsetTop; while (a = a.offsetParent);
                    return b
                },
                isActive: function (a) {
                    return a === document.activeElement && (a.type || a.href)
                }
            };
        return e
    }(dat.utils.common), dat.controllers.OptionController = function (a, b, c) {
        var d = function (a, e, f) {
            d.superclass.call(this, a, e);
            var g = this;
            if (this.__select = document.createElement("select"), c.isArray(f)) {
                var h = {};
                c.each(f, function (a) {
                    h[a] = a
                }), f = h
            }
            c.each(f, function (a, b) {
                var c = document.createElement("option");
                c.innerHTML = b, c.setAttribute("value", a), g.__select.appendChild(c)
            }), this.updateDisplay(), b.bind(this.__select, "change", function () {
                g.setValue(this.options[this.selectedIndex].value)
            }), this.domElement.appendChild(this.__select)
        };
        return d.superclass = a, c.extend(d.prototype, a.prototype, {
            setValue: function (a) {
                return a = d.superclass.prototype.setValue.call(this, a), this.__onFinishChange && this.__onFinishChange.call(this, this.getValue()), a
            },
            updateDisplay: function () {
                return this.__select.value = this.getValue(), d.superclass.prototype.updateDisplay.call(this)
            }
        }), d
    }(dat.controllers.Controller, dat.dom.dom, dat.utils.common), dat.controllers.NumberController = function (a, b) {
        function c(a) {
            return a = a.toString(), -1 < a.indexOf(".") ? a.length - a.indexOf(".") - 1 : 0
        }
        var d = function (a, e, f) {
            d.superclass.call(this, a, e), f = f || {}, this.__min = f.min, this.__max = f.max, this.__step = f.step, b.isUndefined(this.__step) ? this.__impliedStep = 0 == this.initialValue ? 1 : Math.pow(10, Math.floor(Math.log(Math.abs(this.initialValue)) / Math.LN10)) / 10 : this.__impliedStep = this.__step, this.__precision = c(this.__impliedStep)
        };
        return d.superclass = a, b.extend(d.prototype, a.prototype, {
            setValue: function (a) {
                return void 0 !== this.__min && a < this.__min ? a = this.__min : void 0 !== this.__max && a > this.__max && (a = this.__max), void 0 !== this.__step && 0 != a % this.__step && (a = Math.round(a / this.__step) * this.__step), d.superclass.prototype.setValue.call(this, a)
            },
            min: function (a) {
                return this.__min = a, this
            },
            max: function (a) {
                return this.__max = a, this
            },
            step: function (a) {
                return this.__impliedStep = this.__step = a, this.__precision = c(a), this
            }
        }), d
    }(dat.controllers.Controller, dat.utils.common), dat.controllers.NumberControllerBox = function (a, b, c) {
        var d = function (a, e, f) {
            function g() {
                var a = parseFloat(k.__input.value);
                c.isNaN(a) || k.setValue(a)
            }

            function h(a) {
                var b = j - a.clientY;
                k.setValue(k.getValue() + b * k.__impliedStep), j = a.clientY
            }

            function i() {
                b.unbind(window, "mousemove", h), b.unbind(window, "mouseup", i)
            }
            this.__truncationSuspended = !1, d.superclass.call(this, a, e, f);
            var j, k = this;
            this.__input = document.createElement("input"), this.__input.setAttribute("type", "text"), b.bind(this.__input, "change", g), b.bind(this.__input, "blur", function () {
                g(), k.__onFinishChange && k.__onFinishChange.call(k, k.getValue())
            }), b.bind(this.__input, "mousedown", function (a) {
                b.bind(window, "mousemove", h), b.bind(window, "mouseup", i), j = a.clientY
            }), b.bind(this.__input, "keydown", function (a) {
                13 === a.keyCode && (k.__truncationSuspended = !0, this.blur(), k.__truncationSuspended = !1)
            }), this.updateDisplay(), this.domElement.appendChild(this.__input)
        };
        return d.superclass = a, c.extend(d.prototype, a.prototype, {
            updateDisplay: function () {
                var a, b = this.__input;
                if (this.__truncationSuspended) a = this.getValue();
                else {
                    a = this.getValue();
                    var c = Math.pow(10, this.__precision);
                    a = Math.round(a * c) / c
                }
                return b.value = a, d.superclass.prototype.updateDisplay.call(this)
            }
        }), d
    }(dat.controllers.NumberController, dat.dom.dom, dat.utils.common), dat.controllers.NumberControllerSlider = function (a, b, c, d, e) {
        function f(a, b, c, d, e) {
            return d + (a - b) / (c - b) * (e - d)
        }
        var g = function (a, c, d, e, h) {
            function i(a) {
                a.preventDefault();
                var c = b.getOffset(k.__background),
                    d = b.getWidth(k.__background);
                return k.setValue(f(a.clientX, c.left, c.left + d, k.__min, k.__max)), !1
            }

            function j() {
                b.unbind(window, "mousemove", i), b.unbind(window, "mouseup", j), k.__onFinishChange && k.__onFinishChange.call(k, k.getValue())
            }
            g.superclass.call(this, a, c, {
                min: d,
                max: e,
                step: h
            });
            var k = this;
            this.__background = document.createElement("div"), this.__foreground = document.createElement("div"), b.bind(this.__background, "mousedown", function (a) {
                b.bind(window, "mousemove", i), b.bind(window, "mouseup", j), i(a)
            }), b.addClass(this.__background, "slider"), b.addClass(this.__foreground, "slider-fg"), this.updateDisplay(), this.__background.appendChild(this.__foreground), this.domElement.appendChild(this.__background)
        };
        return g.superclass = a, g.useDefaultStyles = function () {
            c.inject(e)
        }, d.extend(g.prototype, a.prototype, {
            updateDisplay: function () {
                var a = (this.getValue() - this.__min) / (this.__max - this.__min);
                return this.__foreground.style.width = 100 * a + "%", g.superclass.prototype.updateDisplay.call(this)
            }
        }), g
    }(dat.controllers.NumberController, dat.dom.dom, dat.utils.css, dat.utils.common, "/**\n * dat-gui JavaScript Controller Library\n * http://code.google.com/p/dat-gui\n *\n * Copyright 2011 Data Arts Team, Google Creative Lab\n *\n * Licensed under the Apache License, Version 2.0 (the \"License\");\n * you may not use this file except in compliance with the License.\n * You may obtain a copy of the License at\n *\n * http://www.apache.org/licenses/LICENSE-2.0\n */\n\n.slider {\n  box-shadow: inset 0 2px 4px rgba(0,0,0,0.15);\n  height: 1em;\n  border-radius: 1em;\n  background-color: #eee;\n  padding: 0 0.5em;\n  overflow: hidden;\n}\n\n.slider-fg {\n  padding: 1px 0 2px 0;\n  background-color: #aaa;\n  height: 1em;\n  margin-left: -0.5em;\n  padding-right: 0.5em;\n  border-radius: 1em 0 0 1em;\n}\n\n.slider-fg:after {\n  display: inline-block;\n  border-radius: 1em;\n  background-color: #fff;\n  border:  1px solid #aaa;\n  content: '';\n  float: right;\n  margin-right: -1em;\n  margin-top: -1px;\n  height: 0.9em;\n  width: 0.9em;\n}"), dat.controllers.FunctionController = function (a, b, c) {
        var d = function (a, c, e) {
            d.superclass.call(this, a, c);
            var f = this;
            this.__button = document.createElement("div"), this.__button.innerHTML = void 0 === e ? "Fire" : e, b.bind(this.__button, "click", function (a) {
                return a.preventDefault(), f.fire(), !1
            }), b.addClass(this.__button, "button"), this.domElement.appendChild(this.__button)
        };
        return d.superclass = a, c.extend(d.prototype, a.prototype, {
            fire: function () {
                this.__onChange && this.__onChange.call(this), this.getValue().call(this.object), this.__onFinishChange && this.__onFinishChange.call(this, this.getValue())
            }
        }), d
    }(dat.controllers.Controller, dat.dom.dom, dat.utils.common), dat.controllers.BooleanController = function (a, b, c) {
        var d = function (a, c) {
            d.superclass.call(this, a, c);
            var e = this;
            this.__prev = this.getValue(), this.__checkbox = document.createElement("input"), this.__checkbox.setAttribute("type", "checkbox"), b.bind(this.__checkbox, "change", function () {
                e.setValue(!e.__prev)
            }, !1), this.domElement.appendChild(this.__checkbox), this.updateDisplay()
        };
        return d.superclass = a, c.extend(d.prototype, a.prototype, {
            setValue: function (a) {
                return a = d.superclass.prototype.setValue.call(this, a), this.__onFinishChange && this.__onFinishChange.call(this, this.getValue()), this.__prev = this.getValue(), a
            },
            updateDisplay: function () {
                return !0 === this.getValue() ? (this.__checkbox.setAttribute("checked", "checked"), this.__checkbox.checked = !0) : this.__checkbox.checked = !1, d.superclass.prototype.updateDisplay.call(this)
            }
        }), d
    }(dat.controllers.Controller, dat.dom.dom, dat.utils.common), dat.color.toString = function (a) {
        return function (b) {
            if (1 == b.a || a.isUndefined(b.a)) {
                for (b = b.hex.toString(16); 6 > b.length;) b = "0" + b;
                return "#" + b
            }
            return "rgba(" + Math.round(b.r) + "," + Math.round(b.g) + "," + Math.round(b.b) + "," + b.a + ")"
        }
    }(dat.utils.common), dat.color.interpret = function (a, b) {
        var c, d, e = [{
            litmus: b.isString,
            conversions: {
                THREE_CHAR_HEX: {
                    read: function (a) {
                        return a = a.match(/^#([A-F0-9])([A-F0-9])([A-F0-9])$/i), null === a ? !1 : {
                            space: "HEX",
                            hex: parseInt("0x" + a[1].toString() + a[1].toString() + a[2].toString() + a[2].toString() + a[3].toString() + a[3].toString())
                        }
                    },
                    write: a
                },
                SIX_CHAR_HEX: {
                    read: function (a) {
                        return a = a.match(/^#([A-F0-9]{6})$/i), null === a ? !1 : {
                            space: "HEX",
                            hex: parseInt("0x" + a[1].toString())
                        }
                    },
                    write: a
                },
                CSS_RGB: {
                    read: function (a) {
                        return a = a.match(/^rgb\(\s*(.+)\s*,\s*(.+)\s*,\s*(.+)\s*\)/), null === a ? !1 : {
                            space: "RGB",
                            r: parseFloat(a[1]),
                            g: parseFloat(a[2]),
                            b: parseFloat(a[3])
                        }
                    },
                    write: a
                },
                CSS_RGBA: {
                    read: function (a) {
                        return a = a.match(/^rgba\(\s*(.+)\s*,\s*(.+)\s*,\s*(.+)\s*\,\s*(.+)\s*\)/), null === a ? !1 : {
                            space: "RGB",
                            r: parseFloat(a[1]),
                            g: parseFloat(a[2]),
                            b: parseFloat(a[3]),
                            a: parseFloat(a[4])
                        }
                    },
                    write: a
                }
            }
        }, {
            litmus: b.isNumber,
            conversions: {
                HEX: {
                    read: function (a) {
                        return {
                            space: "HEX",
                            hex: a,
                            conversionName: "HEX"
                        }
                    },
                    write: function (a) {
                        return a.hex
                    }
                }
            }
        }, {
            litmus: b.isArray,
            conversions: {
                RGB_ARRAY: {
                    read: function (a) {
                        return 3 != a.length ? !1 : {
                            space: "RGB",
                            r: a[0],
                            g: a[1],
                            b: a[2]
                        }
                    },
                    write: function (a) {
                        return [a.r, a.g, a.b]
                    }
                },
                RGBA_ARRAY: {
                    read: function (a) {
                        return 4 != a.length ? !1 : {
                            space: "RGB",
                            r: a[0],
                            g: a[1],
                            b: a[2],
                            a: a[3]
                        }
                    },
                    write: function (a) {
                        return [a.r, a.g, a.b, a.a]
                    }
                }
            }
        }, {
            litmus: b.isObject,
            conversions: {
                RGBA_OBJ: {
                    read: function (a) {
                        return b.isNumber(a.r) && b.isNumber(a.g) && b.isNumber(a.b) && b.isNumber(a.a) ? {
                            space: "RGB",
                            r: a.r,
                            g: a.g,
                            b: a.b,
                            a: a.a
                        } : !1
                    },
                    write: function (a) {
                        return {
                            r: a.r,
                            g: a.g,
                            b: a.b,
                            a: a.a
                        }
                    }
                },
                RGB_OBJ: {
                    read: function (a) {
                        return b.isNumber(a.r) && b.isNumber(a.g) && b.isNumber(a.b) ? {
                            space: "RGB",
                            r: a.r,
                            g: a.g,
                            b: a.b
                        } : !1
                    },
                    write: function (a) {
                        return {
                            r: a.r,
                            g: a.g,
                            b: a.b
                        }
                    }
                },
                HSVA_OBJ: {
                    read: function (a) {
                        return b.isNumber(a.h) && b.isNumber(a.s) && b.isNumber(a.v) && b.isNumber(a.a) ? {
                            space: "HSV",
                            h: a.h,
                            s: a.s,
                            v: a.v,
                            a: a.a
                        } : !1
                    },
                    write: function (a) {
                        return {
                            h: a.h,
                            s: a.s,
                            v: a.v,
                            a: a.a
                        }
                    }
                },
                HSV_OBJ: {
                    read: function (a) {
                        return b.isNumber(a.h) && b.isNumber(a.s) && b.isNumber(a.v) ? {
                            space: "HSV",
                            h: a.h,
                            s: a.s,
                            v: a.v
                        } : !1
                    },
                    write: function (a) {
                        return {
                            h: a.h,
                            s: a.s,
                            v: a.v
                        }
                    }
                }
            }
        }];
        return function () {
            d = !1;
            var a = 1 < arguments.length ? b.toArray(arguments) : arguments[0];
            return b.each(e, function (e) {
                return e.litmus(a) ? (b.each(e.conversions, function (e, f) {
                    return c = e.read(a), !1 === d && !1 !== c ? (d = c, c.conversionName = f, c.conversion = e, b.BREAK) : void 0
                }), b.BREAK) : void 0
            }), d
        }
    }(dat.color.toString, dat.utils.common), dat.GUI = dat.gui.GUI = function (a, b, c, d, e, f, g, h, i, j, k, l, m, n, o) {
        function p(a, b, c, f) {
            if (void 0 === b[c]) throw Error("Object " + b + ' has no property "' + c + '"');
            f.color ? b = new k(b, c) : (b = [b, c].concat(f.factoryArgs), b = d.apply(a, b)), f.before instanceof e && (f.before = f.before.__li), s(a, b), n.addClass(b.domElement, "c"), c = document.createElement("span"), n.addClass(c, "property-name"), c.innerHTML = b.property;
            var g = document.createElement("div");
            return g.appendChild(c), g.appendChild(b.domElement), f = q(a, g, f.before), n.addClass(f, H.CLASS_CONTROLLER_ROW), n.addClass(f, typeof b.getValue()), r(a, f, b), a.__controllers.push(b), b
        }

        function q(a, b, c) {
            var d = document.createElement("li");
            return b && d.appendChild(b), c ? a.__ul.insertBefore(d, params.before) : a.__ul.appendChild(d), a.onResize(), d
        }

        function r(a, b, c) {
            if (c.__li = b, c.__gui = a, o.extend(c, {
                    options: function (b) {
                        return 1 < arguments.length ? (c.remove(), p(a, c.object, c.property, {
                            before: c.__li.nextElementSibling,
                            factoryArgs: [o.toArray(arguments)]
                        })) : o.isArray(b) || o.isObject(b) ? (c.remove(), p(a, c.object, c.property, {
                            before: c.__li.nextElementSibling,
                            factoryArgs: [b]
                        })) : void 0
                    },
                    name: function (a) {
                        return c.__li.firstElementChild.firstElementChild.innerHTML = a, c
                    },
                    listen: function () {
                        return c.__gui.listen(c), c
                    },
                    remove: function () {
                        return c.__gui.remove(c), c
                    }
                }), c instanceof i) {
                var d = new h(c.object, c.property, {
                    min: c.__min,
                    max: c.__max,
                    step: c.__step
                });
                o.each(["updateDisplay", "onChange", "onFinishChange"], function (a) {
                    var b = c[a],
                        e = d[a];
                    c[a] = d[a] = function () {
                        var a = Array.prototype.slice.call(arguments);
                        return b.apply(c, a), e.apply(d, a)
                    }
                }), n.addClass(b, "has-slider"), c.domElement.insertBefore(d.domElement, c.domElement.firstElementChild)
            } else if (c instanceof h) {
                var e = function (b) {
                    return o.isNumber(c.__min) && o.isNumber(c.__max) ? (c.remove(), p(a, c.object, c.property, {
                        before: c.__li.nextElementSibling,
                        factoryArgs: [c.__min, c.__max, c.__step]
                    })) : b
                };
                c.min = o.compose(e, c.min), c.max = o.compose(e, c.max)
            } else c instanceof f ? (n.bind(b, "click", function () {
                n.fakeEvent(c.__checkbox, "click")
            }), n.bind(c.__checkbox, "click", function (a) {
                a.stopPropagation()
            })) : c instanceof g ? (n.bind(b, "click", function () {
                n.fakeEvent(c.__button, "click")
            }), n.bind(b, "mouseover", function () {
                n.addClass(c.__button, "hover")
            }), n.bind(b, "mouseout", function () {
                n.removeClass(c.__button, "hover")
            })) : c instanceof k && (n.addClass(b, "color"), c.updateDisplay = o.compose(function (a) {
                return b.style.borderLeftColor = c.__color.toString(), a
            }, c.updateDisplay), c.updateDisplay());
            c.setValue = o.compose(function (b) {
                return a.getRoot().__preset_select && c.isModified() && y(a.getRoot(), !0), b
            }, c.setValue)
        }

        function s(a, b) {
            var c = a.getRoot(),
                d = c.__rememberedObjects.indexOf(b.object);
            if (-1 != d) {
                var e = c.__rememberedObjectIndecesToControllers[d];
                if (void 0 === e && (e = {}, c.__rememberedObjectIndecesToControllers[d] = e), e[b.property] = b, c.load && c.load.remembered) {
                    if (c = c.load.remembered, c[a.preset]) c = c[a.preset];
                    else {
                        if (!c.Default) return;
                        c = c.Default
                    }
                    c[d] && void 0 !== c[d][b.property] && (d = c[d][b.property], b.initialValue = d, b.setValue(d))
                }
            }
        }

        function t(a) {
            var b = a.__save_row = document.createElement("li");
            n.addClass(a.domElement, "has-save"), a.__ul.insertBefore(b, a.__ul.firstChild), n.addClass(b, "save-row");
            var c = document.createElement("span");
            c.innerHTML = "&nbsp;", n.addClass(c, "button gears");
            var d = document.createElement("span");
            d.innerHTML = "Save", n.addClass(d, "button"), n.addClass(d, "save");
            var e = document.createElement("span");
            e.innerHTML = "New", n.addClass(e, "button"), n.addClass(e, "save-as");
            var f = document.createElement("span");
            f.innerHTML = "Revert", n.addClass(f, "button"), n.addClass(f, "revert");
            var g = a.__preset_select = document.createElement("select");
            if (a.load && a.load.remembered ? o.each(a.load.remembered, function (b, c) {
                    x(a, c, c == a.preset)
                }) : x(a, "Default", !1), n.bind(g, "change", function () {
                    for (var b = 0; b < a.__preset_select.length; b++) a.__preset_select[b].innerHTML = a.__preset_select[b].value;
                    a.preset = this.value
                }), b.appendChild(g), b.appendChild(c), b.appendChild(d), b.appendChild(e), b.appendChild(f), A) {
                var h = function () {
                        i.style.display = a.useLocalStorage ? "block" : "none"
                    },
                    b = document.getElementById("dg-save-locally"),
                    i = document.getElementById("dg-local-explain");
                b.style.display = "block", b = document.getElementById("dg-local-storage"), "true" === localStorage.getItem(document.location.href + ".isLocal") && b.setAttribute("checked", "checked"), h(), n.bind(b, "change", function () {
                    a.useLocalStorage = !a.useLocalStorage, h()
                })
            }
            var j = document.getElementById("dg-new-constructor");
            n.bind(j, "keydown", function (a) {
                !a.metaKey || 67 !== a.which && 67 != a.keyCode || C.hide()
            }), n.bind(c, "click", function () {
                j.innerHTML = JSON.stringify(a.getSaveObject(), void 0, 2), C.show(), j.focus(), j.select()
            }), n.bind(d, "click", function () {
                a.save()
            }), n.bind(e, "click", function () {
                var b = prompt("Enter a new preset name.");
                b && a.saveAs(b)
            }), n.bind(f, "click", function () {
                a.revert()
            })
        }

        function u(a) {
            function b(b) {
                return b.preventDefault(), e = b.clientX, n.addClass(a.__closeButton, H.CLASS_DRAG), n.bind(window, "mousemove", c), n.bind(window, "mouseup", d), !1
            }

            function c(b) {
                return b.preventDefault(), a.width += e - b.clientX, a.onResize(), e = b.clientX, !1
            }

            function d() {
                n.removeClass(a.__closeButton, H.CLASS_DRAG), n.unbind(window, "mousemove", c), n.unbind(window, "mouseup", d)
            }
            a.__resize_handle = document.createElement("div"), o.extend(a.__resize_handle.style, {
                width: "6px",
                marginLeft: "-3px",
                height: "200px",
                cursor: "ew-resize",
                position: "absolute"
            });
            var e;
            n.bind(a.__resize_handle, "mousedown", b), n.bind(a.__closeButton, "mousedown", b), a.domElement.insertBefore(a.__resize_handle, a.domElement.firstElementChild)
        }

        function v(a, b) {
            a.domElement.style.width = b + "px", a.__save_row && a.autoPlace && (a.__save_row.style.width = b + "px"), a.__closeButton && (a.__closeButton.style.width = b + "px")
        }

        function w(a, b) {
            var c = {};
            return o.each(a.__rememberedObjects, function (d, e) {
                var f = {};
                o.each(a.__rememberedObjectIndecesToControllers[e], function (a, c) {
                    f[c] = b ? a.initialValue : a.getValue()
                }), c[e] = f
            }), c
        }

        function x(a, b, c) {
            var d = document.createElement("option");
            d.innerHTML = b, d.value = b, a.__preset_select.appendChild(d), c && (a.__preset_select.selectedIndex = a.__preset_select.length - 1)
        }

        function y(a, b) {
            var c = a.__preset_select[a.__preset_select.selectedIndex];
            c.innerHTML = b ? c.value + "*" : c.value
        }

        function z(a) {
            0 != a.length && l(function () {
                z(a)
            }), o.each(a, function (a) {
                a.updateDisplay()
            })
        }
        a.inject(c);
        var A;
        try {
            A = "localStorage" in window && null !== window.localStorage
        } catch (B) {
            A = !1
        }
        var C, D, E = !0,
            F = !1,
            G = [],
            H = function (a) {
                function b() {
                    var a = c.getRoot();
                    a.width += 1, o.defer(function () {
                        --a.width
                    })
                }
                var c = this;
                this.domElement = document.createElement("div"), this.__ul = document.createElement("ul"), this.domElement.appendChild(this.__ul), n.addClass(this.domElement, "dg"), this.__folders = {}, this.__controllers = [], this.__rememberedObjects = [], this.__rememberedObjectIndecesToControllers = [], this.__listening = [], a = a || {}, a = o.defaults(a, {
                    autoPlace: !0,
                    width: H.DEFAULT_WIDTH
                }), a = o.defaults(a, {
                    resizable: a.autoPlace,
                    hideable: a.autoPlace
                }), o.isUndefined(a.load) ? a.load = {
                    preset: "Default"
                } : a.preset && (a.load.preset = a.preset), o.isUndefined(a.parent) && a.hideable && G.push(this), a.resizable = o.isUndefined(a.parent) && a.resizable, a.autoPlace && o.isUndefined(a.scrollable) && (a.scrollable = !0);
                var d, e = A && "true" === localStorage.getItem(document.location.href + ".isLocal");
                if (Object.defineProperties(this, {
                        parent: {
                            get: function () {
                                return a.parent
                            }
                        },
                        scrollable: {
                            get: function () {
                                return a.scrollable
                            }
                        },
                        autoPlace: {
                            get: function () {
                                return a.autoPlace
                            }
                        },
                        preset: {
                            get: function () {
                                return c.parent ? c.getRoot().preset : a.load.preset
                            },
                            set: function (b) {
                                for (c.parent ? c.getRoot().preset = b : a.load.preset = b, b = 0; b < this.__preset_select.length; b++) this.__preset_select[b].value == this.preset && (this.__preset_select.selectedIndex = b);
                                c.revert()
                            }
                        },
                        width: {
                            get: function () {
                                return a.width
                            },
                            set: function (b) {
                                a.width = b, v(c, b)
                            }
                        },
                        name: {
                            get: function () {
                                return a.name
                            },
                            set: function (b) {
                                a.name = b, g && (g.innerHTML = a.name)
                            }
                        },
                        closed: {
                            get: function () {
                                return a.closed
                            },
                            set: function (b) {
                                a.closed = b, a.closed ? n.addClass(c.__ul, H.CLASS_CLOSED) : n.removeClass(c.__ul, H.CLASS_CLOSED), this.onResize(), c.__closeButton && (c.__closeButton.innerHTML = b ? H.TEXT_OPEN : H.TEXT_CLOSED)
                            }
                        },
                        load: {
                            get: function () {
                                return a.load
                            }
                        },
                        useLocalStorage: {
                            get: function () {
                                return e
                            },
                            set: function (a) {
                                A && ((e = a) ? n.bind(window, "unload", d) : n.unbind(window, "unload", d), localStorage.setItem(document.location.href + ".isLocal", a))
                            }
                        }
                    }), o.isUndefined(a.parent)) {
                    if (a.closed = !1, n.addClass(this.domElement, H.CLASS_MAIN), n.makeSelectable(this.domElement, !1), A && e) {
                        c.useLocalStorage = !0;
                        var f = localStorage.getItem(document.location.href + ".gui");
                        f && (a.load = JSON.parse(f))
                    }
                    this.__closeButton = document.createElement("div"), this.__closeButton.innerHTML = H.TEXT_CLOSED, n.addClass(this.__closeButton, H.CLASS_CLOSE_BUTTON), this.domElement.appendChild(this.__closeButton), n.bind(this.__closeButton, "click", function () {
                        c.closed = !c.closed
                    })
                } else {
                    void 0 === a.closed && (a.closed = !0);
                    var g = document.createTextNode(a.name);
                    n.addClass(g, "controller-name"), f = q(c, g), n.addClass(this.__ul, H.CLASS_CLOSED), n.addClass(f, "title"), n.bind(f, "click", function (a) {
                        return a.preventDefault(), c.closed = !c.closed, !1
                    }), a.closed || (this.closed = !1)
                }
                a.autoPlace && (o.isUndefined(a.parent) && (E && (D = document.createElement("div"), n.addClass(D, "dg"), n.addClass(D, H.CLASS_AUTO_PLACE_CONTAINER), document.body.appendChild(D), E = !1), D.appendChild(this.domElement), n.addClass(this.domElement, H.CLASS_AUTO_PLACE)), this.parent || v(c, a.width)), n.bind(window, "resize", function () {
                    c.onResize()
                }), n.bind(this.__ul, "webkitTransitionEnd", function () {
                    c.onResize()
                }), n.bind(this.__ul, "transitionend", function () {
                    c.onResize()
                }), n.bind(this.__ul, "oTransitionEnd", function () {
                    c.onResize()
                }), this.onResize(), a.resizable && u(this), this.saveToLocalStorageIfPossible = d = function () {
                    A && "true" === localStorage.getItem(document.location.href + ".isLocal") && localStorage.setItem(document.location.href + ".gui", JSON.stringify(c.getSaveObject()))
                }, c.getRoot(), a.parent || b()
            };
        return H.toggleHide = function () {
            F = !F, o.each(G, function (a) {
                a.domElement.style.zIndex = F ? -999 : 999, a.domElement.style.opacity = F ? 0 : 1
            })
        }, H.CLASS_AUTO_PLACE = "a", H.CLASS_AUTO_PLACE_CONTAINER = "ac", H.CLASS_MAIN = "main", H.CLASS_CONTROLLER_ROW = "cr", H.CLASS_TOO_TALL = "taller-than-window", H.CLASS_CLOSED = "closed", H.CLASS_CLOSE_BUTTON = "close-button", H.CLASS_DRAG = "drag", H.DEFAULT_WIDTH = 245, H.TEXT_CLOSED = "Close Controls", H.TEXT_OPEN = "Open Controls", n.bind(window, "keydown", function (a) {
            "text" === document.activeElement.type || 72 !== a.which && 72 != a.keyCode || H.toggleHide()
        }, !1), o.extend(H.prototype, {
            add: function (a, b) {
                return p(this, a, b, {
                    factoryArgs: Array.prototype.slice.call(arguments, 2)
                })
            },
            addColor: function (a, b) {
                return p(this, a, b, {
                    color: !0
                })
            },
            remove: function (a) {
                this.__ul.removeChild(a.__li), this.__controllers.splice(this.__controllers.indexOf(a), 1);
                var b = this;
                o.defer(function () {
                    b.onResize()
                })
            },
            destroy: function () {
                this.autoPlace && D.removeChild(this.domElement)
            },
            addFolder: function (a) {
                if (void 0 !== this.__folders[a]) throw Error('You already have a folder in this GUI by the name "' + a + '"');
                var b = {
                    name: a,
                    parent: this
                };
                return b.autoPlace = this.autoPlace, this.load && this.load.folders && this.load.folders[a] && (b.closed = this.load.folders[a].closed, b.load = this.load.folders[a]), b = new H(b), this.__folders[a] = b, a = q(this, b.domElement), n.addClass(a, "folder"), b
            },
            open: function () {
                this.closed = !1
            },
            close: function () {
                this.closed = !0
            },
            onResize: function () {
                var a = this.getRoot();
                if (a.scrollable) {
                    var b = n.getOffset(a.__ul).top,
                        c = 0;
                    o.each(a.__ul.childNodes, function (b) {
                        a.autoPlace && b === a.__save_row || (c += n.getHeight(b))
                    }), window.innerHeight - b - 20 < c ? (n.addClass(a.domElement, H.CLASS_TOO_TALL), a.__ul.style.height = window.innerHeight - b - 20 + "px") : (n.removeClass(a.domElement, H.CLASS_TOO_TALL), a.__ul.style.height = "auto")
                }
                a.__resize_handle && o.defer(function () {
                    a.__resize_handle.style.height = a.__ul.offsetHeight + "px"
                }), a.__closeButton && (a.__closeButton.style.width = a.width + "px")
            },
            remember: function () {
                if (o.isUndefined(C) && (C = new m, C.domElement.innerHTML = b), this.parent) throw Error("You can only call remember on a top level GUI.");
                var a = this;
                o.each(Array.prototype.slice.call(arguments), function (b) {
                    0 == a.__rememberedObjects.length && t(a), -1 == a.__rememberedObjects.indexOf(b) && a.__rememberedObjects.push(b)
                }), this.autoPlace && v(this, this.width)
            },
            getRoot: function () {
                for (var a = this; a.parent;) a = a.parent;
                return a
            },
            getSaveObject: function () {
                var a = this.load;
                return a.closed = this.closed, 0 < this.__rememberedObjects.length && (a.preset = this.preset, a.remembered || (a.remembered = {}), a.remembered[this.preset] = w(this)), a.folders = {}, o.each(this.__folders, function (b, c) {
                    a.folders[c] = b.getSaveObject()
                }), a
            },
            save: function () {
                this.load.remembered || (this.load.remembered = {}), this.load.remembered[this.preset] = w(this), y(this, !1), this.saveToLocalStorageIfPossible()
            },
            saveAs: function (a) {
                this.load.remembered || (this.load.remembered = {}, this.load.remembered.Default = w(this, !0)), this.load.remembered[a] = w(this), this.preset = a, x(this, a, !0), this.saveToLocalStorageIfPossible()
            },
            revert: function (a) {
                o.each(this.__controllers, function (b) {
                    this.getRoot().load.remembered ? s(a || this.getRoot(), b) : b.setValue(b.initialValue)
                }, this), o.each(this.__folders, function (a) {
                    a.revert(a)
                }), a || y(this.getRoot(), !1)
            },
            listen: function (a) {
                var b = 0 == this.__listening.length;
                this.__listening.push(a), b && z(this.__listening)
            }
        }), H
    }