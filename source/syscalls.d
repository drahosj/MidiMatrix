module rt.syscalls;

import Core.Inc.hal;
import Core.Inc.usart;


void io_putchar(int c)
{
	while (!LL_USART_IsActiveFlag_TXE(USART2)) {}
	LL_USART_TransmitData8(USART2, cast(ubyte) c);
}

extern (C) int _write(int file, char *ptr, int len)
{
	int DataIdx;

	for (DataIdx = 0; DataIdx < len; DataIdx++)
	{
		io_putchar(*ptr++);
	}
	return len;
}

extern (C) void _read() { for(;;){} }

extern (C) void _exit() { for(;;){} }
extern (C) void _kill() { for(;;){} }
extern (C) void _getpid() { for(;;){} }
extern (C) void _close() { for(;;){} }
extern (C) void _fstat() { for(;;){} }
extern (C) void _isatty() { for(;;){} }
extern (C) void _lseek() { for(;;){} }
