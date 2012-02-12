BEGIN {
    printf("Test, cycles, instructions:");
}
/Performance/ {
    printf("\n%s ", $0);
}
/cycles/ {
    printf("%'.0fK ", $1/1000);
}
/instructions/ {
    printf("%'.0fK",$1/1000);
}

END {printf("\n");}
