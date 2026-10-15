#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import logging
logger = logging.getLogger(__name__)

class Individuals(object):
    '''
    Descriptor for all individuals in population.
    '''
    def __init__(self, name):
        self.name = '_{}'.format(name)

    def __get__(self, instance, owner):
        return instance.__dict__[self.name]

    def __set__(self, instance, value):
        instance.__dict__[self.name] = value
        # Update flag.
        instance.update_flag()

class Population(object):
    # All individuals.
    individuals = Individuals('individuals')

    def __init__(self, indv_template, indv_generator, size=100):
        '''
        Class for representing population in genetic algorithm.

        :param indv_template: A template individual to clone all the other
                              individuals in current population.

        :param size: The size of population, number of individuals in population.
        :type size: int

        '''
        # Population size.
        self.size = size
        
        # Template individual.
        self.indv_template = indv_template

        # Generator individual.
        self.indv_generator = indv_generator

        # Flag for monitoring changes of population.
        self._updated = False

        # Container for all individuals.
        class IndvList(list):
            '''
            A proxy class inherited from built-in list to contain all
            individuals which can update the population._updated flag
            automatically when its content is changed.
            '''
            # NOTE: Use 'this' here to avoid name conflict.
            def __init__(this, *args):
                super(this.__class__, this).__init__(*args)

            """def __setitem__(this, key, value):
                '''
                Override __setitem__ in built-in list type.
                '''
                old_value = this[key]
                if old_value == value:
                    return
                super(this.__class__, self).__setitem__(key, value)
                # Update population flag.
                self.update_flag()"""

            def append(this, item):
                '''
                Override append method of built-in list type.
                '''
                super(this.__class__, this).append(item)
                # Update population flag.
                self.update_flag()

            def extend(this, iterable_item):
                if not iterable_item:
                    return
                super(this.__class__, this).extend(iterable_item)
                # Update population flag.
                self.update_flag()
            # }}}

        self._individuals = IndvList()

    # def init(self, indvs=None):
    #     '''
    #     Initialize current population with individuals.

    #     :param indvs: Initial individuals in population, randomly initialized
    #                   individuals are created if not provided.
    #     :type indvs: list of Individual object
    #     '''
    #     IndvType = self.indv_template.__class__

    #     if indvs is None:
    #         while len(self.individuals) < self.size:
    #             indv = IndvType(generator=self.indv_generator).init()
    #             self.individuals.append(indv)
    #     else:
    #         # Check individuals.
    #         if len(indvs) != self.size:
    #             raise ValueError('Invalid individuals number')
    #         # for indv in indvs:
    #         #     if not isinstance(indv, SessionIndividual):
    #         #         raise ValueError('individual class must be Individual or a subclass of Individual')
    #         self.individuals = indvs

    #     self._updated = True
    #     return self

    # ---------------------------ADD------------------------ #
    def init(self, indvs=None):
        IndvType = self.indv_template.__class__

        gen = getattr(self, "indv_generator", None)
        seed_bank = []
        probe_bank = []
        seed_strategy = "prepend"
        if gen is not None:
            seed_strategy = getattr(gen, "seed_strategy", "prepend")
            raw_bank = getattr(gen, "_seed_bank", None)
            if isinstance(raw_bank, list) and raw_bank:
                normalizer = getattr(gen, "_normalize_seed_seq", None)
                if callable(normalizer):
                    for idx, seq in enumerate(raw_bank):
                        try:
                            normalized = normalizer(seq)
                            IndvType(generator=gen).init(chromosome=normalized)
                        except SystemExit as exc:
                            logging.getLogger("Population").warning(
                                "Skipping invalid custom seed at index %d during validation: %s", idx, exc
                            )
                            continue
                        except Exception as exc:
                            logging.getLogger("Population").warning(
                                "Skipping invalid custom seed at index %d during validation: %s", idx, exc
                            )
                            continue
                        seed_bank.append(normalized)
                else:
                    for idx, seq in enumerate(raw_bank):
                        if not isinstance(seq, list) or len(seq) < 1:
                            logging.getLogger("Population").warning("Skipping malformed custom seed at index %d.", idx)
                            continue
                        try:
                            IndvType(generator=gen).init(chromosome=seq)
                        except SystemExit as exc:
                            logging.getLogger("Population").warning(
                                "Skipping invalid custom seed at index %d during validation: %s", idx, exc
                            )
                            continue
                        except Exception as exc:
                            logging.getLogger("Population").warning(
                                "Skipping invalid custom seed at index %d during validation: %s", idx, exc
                            )
                            continue
                        seed_bank.append(seq)
            setattr(gen, "_seed_bank", [])
            probe_generator = getattr(gen, "generate_guard_probe_sequences", None)
            if callable(probe_generator):
                try:
                    probe_bank = probe_generator()
                except Exception as exc:
                    logging.getLogger("Population").warning(
                        "Failed to generate coverage guard probes: %s", exc
                    )
                    probe_bank = []
            vulnerability_probe_generator = getattr(gen, "generate_vulnerability_probe_sequences", None)
            if callable(vulnerability_probe_generator):
                try:
                    probe_bank.extend(vulnerability_probe_generator())
                except Exception as exc:
                    logging.getLogger("Population").warning(
                        "Failed to generate vulnerability hint probes: %s", exc
                    )

        if indvs is not None:
            if len(indvs) != self.size:
                raise ValueError('Invalid individuals number')
            self.individuals = indvs
            self._updated = True
            return self

        def log_seed(seq):
            try:
                origin = None
                seed_id = None
                if isinstance(seq, list) and seq and isinstance(seq[0], dict):
                    origin = seq[0].get("__origin__")
                    seed_id = seq[0].get("__seed_id__")
                first = seq[0] if isinstance(seq, list) and seq else {}
                func_or_sel = first.get("function") or first.get("selector") or "constructor"
                to_addr = first.get("to") or first.get("contract") or ""
                data_len = len((first.get("data") or "")) // 2 if first.get("data") else 0
                logging.getLogger("Population").info(
                    "[POP-SEED][seed=%s] origin=%s first_tx func=%s to=%s data_len=%d",
                    str(seed_id), str(origin), str(func_or_sel), str(to_addr), data_len
                )
            except Exception as _e:
                logging.getLogger("Population").warning("[POP-SEED] log-fail: %s", _e)

        def append_probes():
            for seq in probe_bank:
                if len(self.individuals) >= self.size:
                    break
                try:
                    log_seed(seq)
                    self.individuals.append(IndvType(generator=self.indv_generator).init(chromosome=seq))
                except Exception as exc:
                    logging.getLogger("Population").warning(
                        "Skipping invalid coverage guard probe: %s", exc
                    )

        if seed_strategy == "random":
            append_probes()
            while len(self.individuals) < self.size:
                self.individuals.append(IndvType(generator=self.indv_generator).init())
            self._updated = True
            return self

        if not seed_bank:
            if seed_strategy == "only":
                logging.getLogger("Population").warning(
                    "--seed-strategy only received no valid custom seeds; falling back to random initialization."
                )
            append_probes()
            while len(self.individuals) < self.size:
                self.individuals.append(IndvType(generator=self.indv_generator).init())
            self._updated = True
            return self

        if seed_strategy == "only":
            selected_seeds = seed_bank[:self.size]
            for seq in selected_seeds:
                # --- POP-SEED LOG START ---
                log_seed(seq)
                # --- POP-SEED LOG END ---
                self.individuals.append(IndvType(generator=self.indv_generator).init(chromosome=seq))
            append_probes()
            self.size = len(self.individuals)
            self._updated = True
            return self

        #种子+随机
        if seed_strategy == "prepend":
            for seq in seed_bank[:self.size]:
                # --- POP-SEED LOG START ---
                log_seed(seq)
                # --- POP-SEED LOG END ---
                self.individuals.append(IndvType(generator=self.indv_generator).init(chromosome=seq))
            append_probes()
            while len(self.individuals) < self.size:
                self.individuals.append(IndvType(generator=self.indv_generator).init())
            self._updated = True
            return self

        raise ValueError("Unknown seed strategy: {}".format(seed_strategy))


    def update_flag(self):
        '''
        Interface for updating individual update flag to True.
        '''
        self._updated = True

    @property
    def updated(self):
        '''
        Query function for population updating flag.
        '''
        return self._updated

    def new(self):
        '''
        Create a new emtpy population.
        '''
        return self.__class__(indv_template=self.indv_template, size=self.size)

    def __getitem__(self, key):
        '''
        Get individual by index.
        '''
        if key < 0 or key >= self.size:
            raise IndexError('Individual index({}) out of range'.format(key))
        return self.individuals[key]

    def __len__(self):
        '''
        Get length of population.
        '''
        return len(self.individuals)

    def best_indv(self, fitness):
        '''
        The individual with the best fitness.

        '''
        all_fits = self.all_fits(fitness)
        return max(self.individuals, key=lambda indv: all_fits[self.individuals.index(indv)])

    def worst_indv(self, fitness):
        '''
        The individual with the worst fitness.
        '''
        all_fits = self.all_fits(fitness)
        return min(self.individuals, key=lambda indv: all_fits[self.individuals.index(indv)])

    def max(self, fitness):
        '''
        Get the maximum fitness value in population.
        '''
        all_fits = self.all_fits(fitness)
        if not all_fits:
            return 0
        return max(all_fits)

    def min(self, fitness):
        '''
        Get the minimum value of fitness in population.
        '''
        all_fits = self.all_fits(fitness)
        if not all_fits:
            return 0
        return min(all_fits)

    def mean(self, fitness):
        '''
        Get the average fitness value in population.
        '''
        all_fits = self.all_fits(fitness)
        if not all_fits:
            return 0
        return sum(all_fits)/len(all_fits)

    def all_fits(self, fitness):
        '''
        Get all fitness values in population.
        '''
        return [fitness(indv) for indv in self.individuals]
