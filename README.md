# Subdom Radar

This script helps you find subdomains for a target domain and check which ones are alive.

## What it does

* Runs **assetfinder**, **alterx**, and **subfinder** to collect subdomains.
* Merges everything into one deduplicated list.
* Uses **httpx** to check which subdomains are live.
* Saves results in the `result/` folder with numbered files.

## Requirements

Make sure these tools are installed:

* assetfinder
* alterx
* subfinder
* httpx

## Usage

Run the script with a target domain:

```bash
./subdom_radar.sh target.com
```

Example:

```bash
./subdom_radar.sh example.com
```

## Output files

Inside the `result/` folder you will see:

* `fileN1.txt` from assetfinder
* `fileN2.txt` from alterx
* `fileN3.txt` from subfinder
* `total_subdomN.txt` merged and cleaned list
* `total_live_subdomN.txt` only live subdomains

`N` increases every time you run the script.

## Notes

* If there is a file named `total_target.txt` in the same folder, httpx will use it instead of the generated list.
* The script ignores errors and keeps the output clean.

## Tip

You can automate the installation of required tools first, then run the script for fast recon.

## If you find any error please report it. 
