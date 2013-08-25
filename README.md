ESCssParser
===========

ESCssParser is a css parser for Objective-C. you can use it to parser some simple CSS to NSDictionary.

###how to use:

```objective-c
ESCssParser *parser = [[ESCssParser alloc] init];
NSDictionary *styleSheet = [parser parseText:cssText];
NSLog(@"styleSheet: %@", styleSheet);
```

###css file:
```css
/*this file is just for test*/
@charset "utf-8";

*{ margin:5px 10px; font-size:17px; color:rgb(200,200,200); }

#idSelector{
    background-image:url(../images/someImg.png);
    width:200px;
    height:150px;
}

.classSelector{
    display: black;
    border-width: 5px;
    border-color: #ababab;
    border-radius: 8px;
    
    -webkit-animation-name: myAnimation;
    -webkit-animation-duration:3s;
    -webkit-animation-timing-function:ease-in-out;
    -webkit-animation-iteration-count:3;
}

@-webkit-keyframes myAnimation{
    from{ width:500px; height:400px; background-color:red;}
    to{width:300px; height:200px; background-color:#fff;}
}

div{
    padding-left:5px;
    padding-top:10px;
    text-align:center;
}

```

###result:
```log
styleSheet: {
    "#idSelector" =     {
        "background-image" = "url(../images/someImg.png)";
        height = 150px;
        width = 200px;
    };
    "*" =     {
        color = "rgb(200, 200, 200)";
        "font-size" = 17px;
        margin = "5px 10px";
    };
    "-webkit-keyframes myAnimation" =     {
        from =         {
            "background-color" = red;
            height = 400px;
            width = 500px;
        };
        to =         {
            "background-color" = "#fff";
            height = 200px;
            width = 300px;
        };
    };
    ".classSelector" =     {
        "-webkit-animation-duration" = 3s;
        "-webkit-animation-iteration-count" = 3;
        "-webkit-animation-name" = myAnimation;
        "-webkit-animation-timing-function" = "ease-in-out";
        "border-color" = "#ababab";
        "border-radius" = 8px;
        "border-width" = 5px;
        display = black;
    };
    div =     {
        "padding-left" = 5px;
        "padding-top" = 10px;
        "text-align" = center;
    };
}
```
