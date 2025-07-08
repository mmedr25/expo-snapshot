# @mmedr25/expo-snapshot

A custom Expo module for capturing native snapshots on iOS and Android using the Expo Modules API.

---

## Features

- 📸 Capture native snapshots of screens or views  
- 🖼️ Supports `png` and `jpg` formats  
- ⚙️ Adjustable `quality` for JPG compression (`0` - `100`)
- 🔥 Returns **raw Base64 string** (no `data:image/...;base64,` prefix)  
- 🚀 Seamless integration with Expo & EAS Build  

---

## Installation

```bash
npm install @mmedr25/expo-snapshot
# or
yarn add @mmedr25/expo-snapshot
```

---

## Usage

```tsx
import React from 'react';
import { Button, View, Image } from 'react-native';
import * as Snapshot from '@mmedr25/expo-snapshot';

export default function App() {
  const [dataUri, setDataUri] = React.useState<string | null>(null);

  const takeSnapshot = async () => {
    try {
      const result = await Snapshot.captureScreen({
        format: 'jpg',   // 'png' or 'jpg'
        quality: 80,    // only for 'jpg'
      });

      // result.base64 is raw Base64 (no prefix)
      setDataUri(`data:image/jpg;base64,${result.base64}`);
    } catch (err) {
      console.error('Snapshot error:', err);
    }
  };

  return (
    <View style={{ flex: 1, justifyContent: 'center', alignItems: 'center' }}>
      <Button title="Take Snapshot" onPress={takeSnapshot} />
      {dataUri && (
        <Image
          source={{ uri: dataUri }}
          style={{ width: 200, height: 200, marginTop: 20 }}
        />
      )}
    </View>
  );
}
```