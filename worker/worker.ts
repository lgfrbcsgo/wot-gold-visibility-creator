import {expose} from 'comlink';
import {CreatePackageFunction} from './types';

const wasm = import('./wasm/pkg');

const createPackage: CreatePackageFunction = async (color, textureForward, textureDeferred) => {
    const { r, g, b, alpha } = color;

    return (await wasm).create_package(
        r, g, b, alpha,
        textureForward.data, textureForward.height, textureForward.width, textureForward.path,
        textureDeferred.data, textureDeferred.height, textureDeferred.width, textureDeferred.path
    );
};

expose(createPackage);