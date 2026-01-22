#! /bin/bash

typst compile manuscript/model.typ figures/model.svg
quarto render
