====
ferm
====

Install and configure `ferm <http://ferm.foo-projects.org/>`_ "to maintain 
complex firewalls".

.. note::

    See the full `Salt Formulas installation and usage instructions
    <http://docs.saltstack.com/en/latest/topics/development/conventions/formulas.html>`_.

Available states
================

.. contents::
    :local:


``ferm``
---------------

Install packages, configure it and apply.

``ferm.package``
---------------

Install ferm package.

``ferm.config``
---------------

Configure ferm, and apply.

``ferm.service``
---------------

Apply, and ensure service is launched at boot.
