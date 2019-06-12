interface Window {
    WebAssembly: typeof WebAssembly;
}

declare module 'text-encoding' {
    export const TextDecoder: typeof window.TextDecoder;
    export const TextEncoder: typeof window.TextEncoder;
}