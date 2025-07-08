import SnapshotModule from '@mmedr25/expo-snapshot';
import { Button, Pressable, SafeAreaView, Text } from 'react-native';

const options = {
  format: 'jpg',
  quality: 100
} as const

export default function App() {
  const onPress = async () => {
    try {
      const image = await SnapshotModule.captureScreen(options)
      console.log("🚀 ~ onPress ~ image:", image)
      
    } catch (error) {
      console.log("🚀 ~ onPress ~ error:", error)
    }
    
  }
  return (
    <SafeAreaView style={styles.container}>
      <Pressable onPress={onPress} style={styles.button}>
        <Text>press me</Text>
      </Pressable>
    </SafeAreaView>
  );
}



const styles = {
  button: {
    padding: 30,
    margin: 20,
    borderWidth: 1,
    borderColor: "#000000"
  },
  container: {
    flex: 1,
    backgroundColor: "#FFFFFF"
  },
};
