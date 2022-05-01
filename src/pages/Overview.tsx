import {
    IonHeader,
    IonProgressBar,
    IonTitle,
} from '@ionic/react';
import './Overview.css';
import {getCurrentDate, getDateLastYear} from "../util/dateUtility";
import {useEffect, useState} from "react";
import {fetchEarthQuakeDataLastYear} from "../util/dataUtility";


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
        <IonHeader>Loading</IonHeader> //<IonProgressBar type="indeterminate" reversed={true}/>
    );

    if (!earthQuakesLastYear) return (
        <IonHeader><IonTitle>Data not available</IonTitle></IonHeader>
    );

    return (
            <IonHeader>
                <IonTitle>{JSON.stringify(earthQuakesLastYear)}</IonTitle>
            </IonHeader>
    );
};

export default Overview;
