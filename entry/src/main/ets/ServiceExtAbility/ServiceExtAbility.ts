
import ServiceExtensionAbility from '@ohos.app.ability.ServiceExtensionAbility';

const TAG: string = "[PComputer]";

export default class ServiceExtAbility extends ServiceExtensionAbility {
  onCreate(want) {
    console.info(TAG, `onCreate, want: ${want.abilityName}`);
  }

  onRequest(want, startId) {
    console.info(TAG, `onRequest, want: ${want.abilityName}`);
  }

  onConnect(want) {
    console.info(TAG, `onConnect, want: ${want.abilityName}`);
    return null;
  }

  onDisconnect(want) {
    console.info(TAG, `onDisconnect, want: ${want.abilityName}`);
  }

  onDestroy() {
    console.info(TAG, `onDestroy`);
  }
}