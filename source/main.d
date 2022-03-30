module main;

import Core.Inc.main;

/* hack */
extern (C) void SystemClock_Config();

import Core.Inc.gpio;
import Core.Inc.usart;

extern (C) void main()
{
    SystemClock_Config();
    MX_GPIO_Init();
    MX_USART1_UART_Init();
    MX_USART2_UART_Init();

    for(;;) {}
}
