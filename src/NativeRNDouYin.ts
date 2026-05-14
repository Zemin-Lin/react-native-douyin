import type { TurboModule } from 'react-native';
import { TurboModuleRegistry } from 'react-native';

export interface Spec extends TurboModule {
  init(appKey: string): void;

  auth(scope: string,state:string,appLink:string): Promise<any>;

   shareVideo(shareConfig: {
    videos: string[];
    isPublish?: boolean;
    title?: string;
    shortTitle?: string;
  }): Promise<any>;
  
   isAppInstalled(): boolean;

}

export default TurboModuleRegistry.getEnforcing<Spec>("DouYinModule");