import {WorkerOptions} from './types';

export type State = Idle | AwaitingBitmapForward | AwaitingBitmapDeferred | Running;

export enum StateType {
    Idle,
    AwaitingBitmapForward,
    AwaitingBitmapDeferred,
    Running
}

export class Idle {
    $type: StateType.Idle = StateType.Idle;
}

export class AwaitingBitmapForward {
    $type: StateType.AwaitingBitmapForward = StateType.AwaitingBitmapForward;

    constructor(public options: WorkerOptions) {}
}

export class AwaitingBitmapDeferred {
    $type: StateType.AwaitingBitmapDeferred = StateType.AwaitingBitmapDeferred;

    constructor(public options: WorkerOptions, public bitmapForward: Uint8Array) {}
}

export class Running {
    $type: StateType.Running = StateType.Running;
}
