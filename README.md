PISH - *P*rovision *I*n *SH*ell
===============================

A simple provisioning/system configuration management tool written in `bash`.

Why?
----

I learned Chef, and that seemed complete overkill and complex for what I needed: a way to automate
setting up some virtual machines and my MacBookPro.

If you need anything more complex, there are plenty of decent and fully featured provision and
configuraiton management software out there.

Simplicity
----------

* Write code in `bash` to do work.
* Only supports the provision of a single machine.
* Pretty simple and fast download of software.
* Allow libraries of code that can be shared.
* **PISH** itself has no stored state, it relies only on state gathered from the machine itself.
* Works by *converging* the machine to pass one or more *tests*:
  * A *test* quickly determines if the machine has some particular expected state.
  * If a *test* fails, then *exec* some `bash` script to make it so (if no *exec*, provisioning
    fails).
  * Once *exec* succeeds, then *validate* (or *test*) to ensure that has been updated to the expected
	state, again written in `bash` script.
