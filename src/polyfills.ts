if (!Symbol["asyncIterator"]) {
    (Symbol as any)["asyncIterator"] = Symbol.for("asyncIterator");
}

export async function polyfillTextEncoder() {
    if (!self.TextEncoder || !self.TextDecoder) {
        const {TextEncoder, TextDecoder} = await import('text-encoding');
        self.TextEncoder = self.TextEncoder || TextEncoder;
        self.TextDecoder = self.TextDecoder || TextDecoder;
    }
}