import {AwaitingBitmapDeferred, AwaitingBitmapForward, Idle, Running, State, StateType} from './util/states';
import {WorkerOptions} from './util/types';
import {assert} from "./util/util";

const worker: DedicatedWorkerGlobalScope = self as any;

let state: State = new Idle();

// TODO have a look at https://github.com/GoogleChromeLabs/comlink
worker.addEventListener('message', async ({ data }) => {
    switch (state.$type) {
        case StateType.Idle:
            assert(typeof data === 'object' && data !== null);
            assert(data.color && data.textureForward && data.textureDeferred);
            state = new AwaitingBitmapForward(data);
            break;

        case StateType.AwaitingBitmapForward:
            assert(data instanceof ArrayBuffer);
            state = new AwaitingBitmapDeferred(state.options, new Uint8Array(data));
            break;

        case StateType.AwaitingBitmapDeferred:
            assert(data instanceof ArrayBuffer);
            const bitmapDeferred = new Uint8Array(data);
            const { options, bitmapForward } = state;
            assert(bitmapDeferred.byteLength > bitmapForward.byteLength);

            state = new Running();

            const result = await createPackage(options, bitmapForward, bitmapDeferred);
            worker.postMessage(result.buffer, [result.buffer]);

            state = new Idle();
            break;
    }
});

async function createPackage(options: WorkerOptions, forwardBitmap: Uint8Array, deferredBitmap: Uint8Array): Promise<Uint8Array> {
    const { create_package } = await import('./wasm/pkg');
    const {
        color: { r, g, b, alpha },
        textureForward: forward,
        textureDeferred: deferred
    } = options;

    return create_package(
        r, g, b, alpha,
        forwardBitmap, forward.height, forward.width, forward.path,
        deferredBitmap, deferred.height, deferred.width, deferred.path
    );
}
