import {expose, transfer} from 'comlink';
import {PackageCreator} from './types';

const creator = import('./wasm/pkg');

const createPackage: PackageCreator = async options => {
    const { create_package } = await creator;
    const result = create_package(options);
    return transfer(result, [result.buffer]);
};

expose(createPackage);