import {
  IonButton,
  IonContent,
  IonIcon,
  IonItem,
  IonLabel,
  IonList,
  IonListHeader,
  IonMenu,
  IonMenuToggle,
  IonNote, useIonToast,
} from '@ionic/react';

import {useLocation} from 'react-router-dom';
import {
  barChart,
  barChartOutline,
  earth,
  peopleCircleOutline
} from 'ionicons/icons';
import './Menu.css';
import {useState} from "react";
import {ethers} from 'ethers'
import {getContractAddress, getNetworkStrings} from "../util/chainUtility";
import Overview from "../pages/Overview";

interface AppPage {
  url: string;
  iosIcon: string;
  mdIcon: string;
  title: string;
}

const appPages: AppPage[] = [
  {
    title: 'Overview',
    url: '/page/Overview',
    iosIcon: earth,
    mdIcon: earth
  },
  {
    title: 'Provide Insurance',
    url: '/page/Insure',
    iosIcon: barChartOutline,
    mdIcon: barChart
  },
  {
    title: 'My Insurance',
    url: '/page/Insurance',
    iosIcon: peopleCircleOutline,
    mdIcon: peopleCircleOutline
  }
];


const Menu: React.FC = () => {
  const [defaultNetwork, setDefaultNetwork] = useState('Not connected');
  const [defaultAccount, setDefaultAccount] = useState(null);
  const [userNetworkTokenBalance, setUserNetworkTokenBalance] = useState('');
  const [connButtonText, setConnButtonText] = useState('Connect with MetaMask');
  const [userNetworkSymbol, setUsernetworkSymbol] = useState('');
  const [linkBalance, setLinkBalance] = useState('');
  const [present, dismiss] = useIonToast();
  const location = useLocation();

  const connectWalletHandler = () => {
    if (window.ethereum && window.ethereum.isMetaMask) {
      console.log('MetaMask detected.');

      window.ethereum.request({method: 'eth_requestAccounts'})
          .then((result: any[]) => {
            accountChangedHandler(result[0]);
            setConnButtonText('Wallet Connected');
            getAccountBalance(result[0]);
            const networkStrings = getNetworkStrings(window.ethereum.networkVersion);
            setDefaultNetwork(networkStrings.name);
            setUsernetworkSymbol(networkStrings.symbol)
          })
          .catch((error: { message: string; }) => {
            present(error.message, 5000);

          });

    } else {
      console.log('MetaMask not present.');
      present('Please install the MetaMask browser extension to connect.', 5000);
    }
  };

  // update account, will cause component re-render
  const accountChangedHandler = (newAccount: any) => {
    setDefaultAccount(newAccount);
    getAccountBalance(newAccount.toString());
  };

  const getAccountBalance = (account: string) => {
    window.ethereum.request({method: 'eth_getBalance', params: [account, 'latest']})
        .then((balance: ethers.BigNumberish) => {
          setUserNetworkTokenBalance((ethers.utils.formatEther(balance)));
          const genericErc20Abi = [
            // balanceOf
            {
              constant: true,

              inputs: [{ name: "_owner", type: "address" }],

              name: "balanceOf",

              outputs: [{ name: "balance", type: "uint256" }],

              type: "function",
            },

          ];
          const contract = new ethers.Contract(getContractAddress(window.ethereum.networkVersion, "LINK"), genericErc20Abi, ethers.getDefaultProvider(getNetworkStrings(window.ethereum.networkVersion).defaultRpc));
          contract.balanceOf(account)
                .then((linkBalance: ethers.BigNumberish) =>{
                      setLinkBalance(ethers.utils.formatEther(linkBalance));
                    }
                )
        })
        .catch((error: { message: string; }) => {
          present(error.message, 5000);
        });
  };

  const chainChangedHandler = () => {
    // reload the page to avoid any errors with chain change mid use of application
    window.location.reload();
  };


  // listen for account changes
  if (window.ethereum || window.ethereum.on){
    window.ethereum.on('accountsChanged', accountChangedHandler);
    window.ethereum.on('chainChanged', chainChangedHandler);
  }

  return (
    <IonMenu contentId="main" type="overlay">
      <IonContent>
        <IonList id="quakeVault-list">
          <IonListHeader><IonLabel>Network: {defaultNetwork}</IonLabel><IonButton onClick={connectWalletHandler}>{connButtonText}</IonButton></IonListHeader>
          <IonNote>Address: {defaultAccount}</IonNote>

          <IonNote>Native Token Balance: {userNetworkTokenBalance} {userNetworkSymbol}</IonNote>
          <IonNote>Chainlink Balance: {linkBalance} LINK</IonNote>
          {appPages.map((appPage, index) => {
            return (
              <IonMenuToggle key={index} autoHide={false}>
                <IonItem className={location.pathname === appPage.url ? 'selected' : ''} routerLink={appPage.url} routerDirection="none" lines="none" detail={false}>
                  <IonIcon slot="start" ios={appPage.iosIcon} md={appPage.mdIcon} />
                  <IonLabel>{appPage.title}</IonLabel>
                </IonItem>
              </IonMenuToggle>
            );
          })}
        </IonList>

        <IonList id="about-list">
          <IonListHeader>About</IonListHeader>
        </IonList>
      </IonContent>
    </IonMenu>
  );
};

export default Menu;
