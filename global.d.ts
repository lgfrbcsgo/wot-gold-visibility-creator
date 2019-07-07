declare module 'text-encoding' {
    export const TextDecoder: typeof window.TextDecoder;
    export const TextEncoder: typeof window.TextEncoder;
}

interface Window {
    [key: string]: Worker;
}
