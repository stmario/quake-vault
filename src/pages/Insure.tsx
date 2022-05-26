import './Insure.css'
import {IonButton, IonHeader, IonInput, IonItem, IonList, IonListHeader, IonTitle} from "@ionic/react";
import {useState} from "react";
const Insure: React.FC = () => {
    const [stakeAmount, setStakeAmount] = useState<number>();
    const [startUnstakeAmount, setStartUnstakeAmount] = useState<number>();
    const [unstakeAmount, setUnstakeAmount] = useState<number>();

    return (
        <IonHeader>
            <IonListHeader><IonTitle>Currently staking</IonTitle></IonListHeader>
            <IonList>
                <IonItem>11'432 Dai</IonItem>
                <IonItem>
                    <IonInput value={startUnstakeAmount} placeholder="Enter unstake amount" onIonChange={e => setStartUnstakeAmount(+e.detail.value!)}/>
                    <IonButton color="secondary">Start 14 days unstaking</IonButton>
                </IonItem>
            </IonList>
            <IonListHeader><IonTitle>Pending unstaking</IonTitle></IonListHeader>
            <IonList>
                <IonItem>1'721 Dai, days remaining: 0</IonItem>
                <IonItem>
                    <IonInput value={unstakeAmount} placeholder="Enter unstake amount" onIonChange={e => setUnstakeAmount(+e.detail.value!)}/>
                    <IonButton color="secondary">Unstake</IonButton>
                </IonItem>
            </IonList>
            <IonListHeader><IonTitle>Pending rewards</IonTitle></IonListHeader>
            <IonList>
                <IonItem>123 Dai, 14 QVT</IonItem>
                <IonItem><IonButton color="secondary">Claim</IonButton><IonButton>Restake</IonButton></IonItem>
            </IonList>
            <IonListHeader><IonTitle>Provide Insurance</IonTitle></IonListHeader>
            <IonList>
                <IonItem>
                    <IonInput value={stakeAmount} placeholder="Enter stake amount" onIonChange={e => setStakeAmount(+e.detail.value!)}/>
                    <IonButton>Stake</IonButton>
                </IonItem>
            </IonList>
        </IonHeader>
    )
};

export default Insure;
