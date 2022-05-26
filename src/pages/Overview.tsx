import {
    IonHeader, IonItem, IonList, IonListHeader,
    IonProgressBar,
    IonTitle,
} from '@ionic/react';
import './Overview.css';
import {getCurrentDate, getDateLastYear} from "../util/dateUtility";
import {useEffect, useState} from "react";
import {earthquakeResponseJSON, fetchEarthQuakeDataLastYear} from "../util/dataUtility";


const Overview: React.FC = () => {
    const [earthQuakesLastYear, setEarthQuakesLastYear] = useState<JSON | undefined>(undefined);
    const [loading, setLoading] = useState(true);

    const today = getCurrentDate("-");
    console.log("Today: ", today);
    const lastYearDate = getDateLastYear("-");
    console.log("Last Year: ", lastYearDate);

    console.log("Fetching EQ data...");
    useEffect(() => {
        fetchEarthQuakeDataLastYear().then((response: Response) => {
            response.json().then((json: JSON) => {
                setEarthQuakesLastYear(json);
                setLoading(false);
            })
                .catch(reason => console.log(reason))
        })
    }, []);
    console.log(earthQuakesLastYear);

    if(loading) return (
        <IonHeader><IonProgressBar type="indeterminate" reversed={true}/></IonHeader>
    );

    if (!earthQuakesLastYear) return (
        <IonHeader><IonTitle>Data not available</IonTitle></IonHeader>
    );

    return (
            <IonHeader>
                <IonTitle>Total value locked: 49'239$ (43'423 Dai, 4'543 QVT) </IonTitle>
                <IonTitle>Current insurance staking ratio: 2.3%</IonTitle>
                <IonList>
                    <IonListHeader><IonTitle>Recent Earthquakes:</IonTitle></IonListHeader>
                    {(JSON.parse(JSON.stringify(earthQuakesLastYear)) as earthquakeResponseJSON).features.map((feature: JSON) => {return (<IonTitle>{JSON.stringify(feature)}</IonTitle>)})}
                </IonList>
            </IonHeader>
    );
};

export default Overview;
