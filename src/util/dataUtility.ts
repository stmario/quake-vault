import {getCurrentDate, getDateLastYear} from "./dateUtility";

const usgsAPI = "https://earthquake.usgs.gov/fdsnws/event/1/query?format=geojson";

const validityFilters = "&eventtype=earthquake&minmmi=7";

export async function fetchEarthQuakeDataLastYear() {
    const dateFilters = "&starttime=" + getDateLastYear() +"&endtime=" + getCurrentDate();

    const query = usgsAPI + validityFilters + dateFilters;
    console.log(query);

    return await window.fetch(query);
}

export interface earthquakeResponseJSON {
    type: string;
    metadata: JSON; //TODO: add details
    features: [JSON];
    bbox: [number];
}
