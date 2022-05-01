import './Insurance.css'
import {IonButton, IonContent, IonHeader, IonInput, IonItem, IonRange} from "@ionic/react";
import {useState} from "react";
const Insurance: React.FC = () => {
    const [text, setText] = useState<string>();
    const [number, setNumber] = useState<number>();
    return (
        <IonContent>
            <IonHeader>You are insured at XXX // YYY with XY days remaining</IonHeader>
            <IonItem>
                <IonInput value={text} placeholder="Enter Input" onIonChange={e => setText(e.detail.value!)}></IonInput>
            </IonItem>
            <IonItem>
                <IonRange min={0} max={10} step={1} snaps={true}/>
            </IonItem>
            <IonButton>Buy Insurance</IonButton>
            <IonButton color="secondary">Claim Insurance</IonButton>
        </IonContent>
    )
};

export default Insurance;
