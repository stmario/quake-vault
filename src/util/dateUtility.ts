export function getCurrentDate(separator='-'){

    let newDate = new Date();
    let date = newDate.getDate();
    let month = newDate.getMonth() + 1;
    let year = newDate.getFullYear();

    return `${year}${separator}${month<10?`0${month}`:`${month}`}${separator}${date}`
}

// TODO: leap years
export function getDateLastYear(separator='-'){
    let newDate = new Date();
    let date = newDate.getDate();
    let month = newDate.getMonth() + 1;
    let year = newDate.getFullYear() - 1;

    return `${year}${separator}${month<10?`0${month}`:`${month}`}${separator}${date}`
}
