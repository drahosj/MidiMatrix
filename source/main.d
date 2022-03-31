module main;

import Core.Inc.main;
/* hack */
extern (C) void SystemClock_Config();

import Core.Inc.gpio;
import Core.Inc.hal;
import Core.Inc.usart;

import ringbuf;
import midi;

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

    printf("midiOut: %x\n", &midiOut);

    puts("Started.");

    if (OutputBuf.full) {
        puts("Somehow output is full");
    }
    if (OutputBuf.empty) {
        puts("Good, output is empty");
    }
    puts("foo");


    sendMidi(Midi(TestMessage.NOTE_ON_1));
    for(int i = 0; i < 30; i++) {
        int retry;
        while(sendMidi(Midi(TestMessage.NOTE_ON_1))) {
            retry++;
        }
        if (retry > 0) {
            printf("Message %d: retries %d\n", i, retry);
        }
    }
    for(int i = 0; i < 8000000; i++) {}
    puts("Should be done by now");

    for(;;) {}
}


__gshared static Ringbuf!(Midi, 16) ForwardBuf;
__gshared static Ringbuf!(Midi, 16) OutputBuf;
__gshared static Midi midiOut;

int sendMidi(Midi m)
{
    if (!OutputBuf.put(m)) {
        LL_USART_EnableIT_TXE(USART1);
        return 0;
    } else {
        return -1;
    }
}

extern (C) void MidiIRQHandler()
{

    if (LL_USART_IsActiveFlag_RXNE(USART1)) {
        ubyte tmp = LL_USART_ReceiveData8(USART1);
        /* state machine stuff */
    }

    if (LL_USART_IsActiveFlag_TXE(USART1)) {
        if (midiOut.raw.length == 0) {
            if (!(OutputBuf.take(midiOut)/* && ForwardBuf.take(midiOut)*/)) {
                assert(midiOut.raw.ptr != null, "midi out ptr is null");
                assert(midiOut.raw.length >= 0, "midi out length is zero");
                LL_USART_TransmitData8(USART1, midiOut.raw[0]);
                midiOut.s++;
            } else {
                LL_USART_DisableIT_TXE(USART1);
            }
        } else {
            LL_USART_TransmitData8(USART1, midiOut.raw[0]);
            midiOut.s++;
        }
    }
}
