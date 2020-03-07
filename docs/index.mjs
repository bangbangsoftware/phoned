import {
  bagItAndTagIt,
  setByName,
  tools
} from "./node_modules/binder/dist/index.js";
import {
  repeaterPlugin,
  addFunction
} from "./node_modules/binder/dist/plugins/repeaterPlugin.js";

const intl = new Intl.DateTimeFormat("en-GB");

export default () => {
  /** 
    console.log("Hello");
    const replace = document.getElementsByTagName("MJHFHG")[0];
    console.log(replace);
    const withThis = document.getElementById("MJHFHG");
    console.log(withThis);
    replace.append(withThis.content.cloneNode(true))
 */

  const diff = (date, now = new Date()) => {
    const timeDiff = date.getTime() - now.getTime();
    const dayDiff = Math.ceil(timeDiff / 86400000);
    if (dayDiff < 7) {
      return dayDiff + " days left";
    }
    const weekDiff = Math.ceil(dayDiff / 7);
    const daysLeft = dayDiff % 7;
    const day = "(" + dayDiff + " days in total)";
    const and =
      daysLeft === 0 ? " left exactly" : " and " + daysLeft + " days left";
    return { text: weekDiff + " weeks" + and, ms: timeDiff, days: day };
  };

  const quick = (dateString, title, now = new Date()) => {
    const date = new Date(dateString);
    const countdown = diff(date, now);
    console.log("");
    console.log(title);
    console.log(date);
    console.log(countdown);
    return {
      date: intl.format(date),
      title: title,
      result: countdown.text,
      days: countdown.days,
      value: countdown.ms
    };
  };

  const dataFn = now => () => {
    console.log("Generating data.... ");
    const corz = quick("11/01/2020", "Cory's birthday", now);
    const countdowns = [corz];

    const mum = quick("01/25/2021", "Mum's birthday", now);
    countdowns.push(mum);
    const dad = quick("07/21/2020", "Dad's birthday", now);
    countdowns.push(dad);
    const finn = quick("04/09/2020", "Finn's birthday", now);
    countdowns.push(finn);

    const sorted = countdowns.sort((c1, c2) => {
      if (c1.value > c2.value) {
        return 1;
      } else if (c1.value < c2.value) {
        return -1;
      }
      return 0;
    });
    return sorted;
  };
  const now = new Date();

  addFunction("countdowns", dataFn(now));
  bagItAndTagIt([repeaterPlugin]);
  setByName("now", intl.format(now));
  const el = document.getElementById("countdowns-title-1");
  tools.clickListener(el, () => {
    el.innerText="YES DAD";
    tools.put(el);
  });
};
