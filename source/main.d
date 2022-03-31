module main;

import Core.Inc.main;
/* hack */
extern (C) void SystemClock_Config();

import Core.Inc.gpio;
import Core.Inc.hal;
import Core.Inc.usart;

import ringbuf;
import midi;
import syscalls;

/* hack */
extern (C) int printf(const char * fmt, ...);
extern (C) int puts(const char * fmt);

__gshared ubyte[4096] emulated_tls_buffer;

extern (C) void * __aeabi_read_tp()
{
    return emulated_tls_buffer.ptr;
}

extern (C) void main()
{
    SystemClock_Config();
    MX_GPIO_Init();
    MX_USART1_UART_Init();
    MX_USART2_UART_Init();

    _write(0, "Started\n", "Started".length);

    for(;;) {}
}


Ringbuf!(Midi, 16) ForwardBuf;
Ringbuf!(Midi, 16) OutputBuf;
Midi midiOut;

bool sendMidi(Midi m)
{
    return false;
}

extern (C) void MidiIRQHandler()
{

    if (LL_USART_IsActiveFlag_RXNE(USART1)) {
        ubyte tmp = LL_USART_ReceiveData8(USART1);
        /* state machine stuff */
    }

    if (LL_USART_IsActiveFlag_TXE(USART1)) {
        if (midiOut.raw.length == 0) {
            if (OutputBuf.take(midiOut) || ForwardBuf.take(midiOut)) {
                LL_USART_TransmitData8(USART1, midiOut.raw[0]);
                midiOut.raw = midiOut.raw[1 .. $];
            } else {
                LL_USART_DisableIT_TXE(USART1);
            }
        } else {
            LL_USART_TransmitData8(USART1, midiOut.raw[0]);
            midiOut.raw = midiOut.raw[1 .. $];
        }
    }
}
