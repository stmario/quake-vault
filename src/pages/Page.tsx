import {
    IonButtons,
    IonContent,
    IonHeader,
    IonMenuButton,
    IonPage,
    IonTitle,
    IonToolbar
} from '@ionic/react';
import { useParams } from 'react-router';
import './Page.css';
import {ReactElement} from "react";
import Overview from "./Overview";
import Insure from "./Insure";
import Insurance from "./Insurance";

interface LoadingProps {

}

const Page: React.FC<LoadingProps> = () => {
  const { name } = useParams<{ name: string; }>();

  const pages: {[name: string]: ReactElement} = {
      "Overview": <Overview/>,
      "Insure": <Insure/>,
      "Insurance": <Insurance/>
  };

  return (
    <IonPage>
      <IonHeader>
        <IonToolbar>
          <IonButtons slot="start">
            <IonMenuButton />
          </IonButtons>
          <IonTitle>{name}</IonTitle>
        </IonToolbar>
      </IonHeader>

      <IonContent fullscreen>
        <IonHeader collapse="condense">
          <IonToolbar>
            <IonTitle size="large">{name}</IonTitle>
          </IonToolbar>
        </IonHeader>
      </IonContent>

        {pages[name]}
    </IonPage>
  );
};

export default Page;
