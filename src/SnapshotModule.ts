import { requireNativeModule } from 'expo';


export type ScreenCaptureOption = {
  format?: "jpg" | "png";
  quality?: number
};

export type SnapshotModuleMethods = {
  captureScreen: (option: ScreenCaptureOption) => Promise<string | unknown>;
}


declare class SnapshotModule implements SnapshotModuleMethods {
  captureScreen: (option: ScreenCaptureOption) => Promise<string | unknown>;
}

// This call loads the native module object from the JSI.
export default requireNativeModule<SnapshotModule>('SnapshotModule');
