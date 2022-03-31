module io;

import Core.Inc.hal;
import Core.Inc.usart;


extern (C) void __io_putchar(int c)
{
	while (!LL_USART_IsActiveFlag_TXE(USART2)) {}
	LL_USART_TransmitData8(USART2, cast(ubyte) c);
}
