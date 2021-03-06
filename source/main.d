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

__gshared GPIO_TypeDef*[] line_ports = [
    GPIOC,
    GPIOC,
    GPIOC,
    GPIOC
];

__gshared uint[] line_pins = [
    LL_GPIO_PIN_0,
    LL_GPIO_PIN_1,
    LL_GPIO_PIN_2,
    LL_GPIO_PIN_3
];

extern (C) void main()
{
    SystemClock_Config();
    MX_GPIO_Init();
    MX_USART1_UART_Init();
    MX_USART2_UART_Init();

    printf("midiOut: %x\n", &midiOut);
    printf("midiOut.test: %d\n", midiOut.test);

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
    for(int i = 0; i < 1000000; i++) {}
    puts("Should be done by now");

    LL_GPIO_ResetOutputPin(line_ports[0], line_pins[0]);
    uint line;
    uint[16] old_input;
    for(;;) {
        for(int i = 0; i < 1000; i++) {}
        uint input = ~(LL_GPIO_ReadInputPort(GPIOB) | 0xffff0800);
        input |= ~(LL_GPIO_ReadInputPort(GPIOA) | 0xFFFFF7FF);
        LL_GPIO_SetOutputPin(line_ports[line], line_pins[line]);
        int next_line = (line + 1) % line_ports.length;
        LL_GPIO_ResetOutputPin(line_ports[next_line], line_pins[next_line]);

        if (input != old_input[line]) {
            foreach(bit; 0 .. 16) {
                uint s = (input >> bit) & 0x1;
                if (s != ((old_input[line] >> bit) & 0x1)) {
                    ubyte[3] raw_midi;
                    raw_midi[0] = cast(ubyte)( 0x80 | (s << 4) | (line >> 2));
                    raw_midi[1] = cast(ubyte)((bit << 2) + line + 36);
                    raw_midi[2] = 64;
                    int retry = 0;
                    while(sendMidi(Midi(raw_midi))) {
                        retry++;
                        if (retry > 250) {
                            printf("Buffer full, dropped message\n");
                        }
                    }
                }
            } 
        }
        old_input[line] = input;
        line = next_line;
    }
}


__gshared static Ringbuf!(Midi, 16) ForwardBuf;
__gshared static Ringbuf!(Midi, 16) OutputBuf;
__gshared static Midi midiOut;

int sendMidi(Midi m)
{
    printf("[MIDI] CHAN_%d %s %d %d\n", m.chan, m.str.ptr, m.num, m.vel);
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
