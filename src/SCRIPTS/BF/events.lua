
return 
{
    press = {
        minus = EVT_MINUS_FIRST,
        plus = EVT_PLUS_FIRST,
        pageDown = EVT_PAGEDN_FIRST,
        pageUp = EVT_PAGEUP_FIRST or EVT_LEFT_BREAK
    },
    longPress = {
        enter = EVT_ENTER_LONG,
        menu = EVT_MENU_LONG or EVT_RIGHT_LONG
    },
    repeatPress = {
        minus = EVT_MINUS_REPT,
        plus = EVT_PLUS_REPT
    },
    release = {
        enter = EVT_ENTER_BREAK,
        exit = EVT_EXIT_BREAK,
        menu = EVT_MENU_BREAK or EVT_RIGHT_BREAK,
        minus = EVT_MINUS_BREAK,
        plus = EVT_PLUS_BREAK
    },
    dial = {
        left = EVT_ROT_LEFT or EVT_UP_BREAK,
        right = EVT_ROT_RIGHT or EVT_DOWN_BREAK
    }
}
