import './Insurance.css'
import {
    IonButton,
    IonContent,
    IonHeader, IonIcon,
    IonInput,
    IonItem,
    IonLabel,
    IonList,
    IonListHeader,
    IonRange, IonTitle
} from "@ionic/react";
import {useState} from "react";
const Insurance: React.FC = () => {
    const [amount, setAmount] = useState<number>();
    const [lat, setLat] = useState<number>();
    const [lon, setLon] = useState<number>();
    const [years, setYears] = useState<number>(1);
    const [daiPerYear, setDaiPerYear] = useState<number>();
    return (
        <IonHeader>
            <IonListHeader><IonTitle>Your insurance:</IonTitle></IonListHeader>
            <IonList>
                <IonItem>41.159, -107.301 || 328 Dai || 148 days remaining</IonItem>
                <IonItem>55.239, -99.532 || 50 Dai || 3 days remaining !!! Earthquake at 55.123, -99.423 with MMI 7.3. 5'020 Dai can be claimed !!!<IonButton color="secondary">Claim Insurance</IonButton></IonItem>
            </IonList>
            <IonListHeader><IonTitle>Buy new insurance</IonTitle></IonListHeader>
            <IonItem>
                <IonLabel>Amount: </IonLabel><IonInput value={amount} placeholder="Enter Amount" onIonChange={e => setAmount(+e.detail.value!)}/>
                <IonLabel>Latitude: </IonLabel><IonInput value={lat}  placeholder="Enter Latitude" onIonChange={e => setLat(+e.detail.value!)}/>
                <IonLabel>Longitude: </IonLabel><IonInput value={lon} placeholder="Enter Longitude" onIonChange={e => setLon(+e.detail.value!)}/>
            </IonItem>
            <IonItem>
                <IonRange min={1} max={10} step={1} snaps={true} onIonChange={e => {setYears(e.detail.value as number); setDaiPerYear(amount!/ (e.detail.value as number))}}/> <IonLabel>{years} years</IonLabel>
            </IonItem>
            <IonItem><IonLabel>Location {lat}, {lon} requires {lat! + lon!} QuakeVaultTokens.</IonLabel> </IonItem>
            <IonItem><IonLabel>With {daiPerYear} Dai per year, you will currently own at least {54 / years}% of the insurance pool in your nearest neighborhood.</IonLabel> </IonItem>
            <IonItem><IonLabel>Current estimated sum covered: {6345 / years} Dai</IonLabel> </IonItem>
            <IonButton>Buy Insurance</IonButton>
        </IonHeader>
    )
};

export default Insurance;
