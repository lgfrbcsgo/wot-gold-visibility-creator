import {wrap, transfer} from "comlink";
import {loadImageData} from './util';
import {Color, CreatePackageFunction, Texture} from './types';

import forwardResourcePath from './res/forward.png';
import deferredResourcePath from './res/deferred.png';
import packagePaths from './res/paths.json';

const createPackage = wrap(
    new Worker('./worker', {type: 'module'})
) as CreatePackageFunction;

export async function run(color: Color): Promise<any> {
    const bitmapForward = await loadImageData(forwardResourcePath);
    const bitmapDeferred = await loadImageData(deferredResourcePath);

    const textureForward: Texture = {
        data: transfer(bitmapForward.data.buffer, [bitmapForward.data.buffer]),
        height: bitmapForward.height,
        width: bitmapForward.width,
        path: packagePaths.forward
    };

    const textureDeferred: Texture = {
        data: transfer(bitmapDeferred.data.buffer, [bitmapDeferred.data.buffer]),
        height: bitmapDeferred.height,
        width: bitmapDeferred.width,
        path: packagePaths.deferred
    };

    return await createPackage(color, textureForward, textureDeferred);
}

