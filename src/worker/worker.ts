import {expose, transfer} from 'comlink';
import {PackageCreator} from "./common";

const createPackage: PackageCreator = async options => {
    const { create_package } = await import('./wasm/pkg');
    const result = create_package(options);
    return transfer(result, [result.buffer]);
};

expose(createPackage);