import {PackageOptions} from "../common";

export type PackageCreator = (options: PackageOptions) => Promise<Uint8Array>;